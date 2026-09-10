import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:homeoffice_api/api.dart';

import 'token_store.dart';

enum AuthMessage {
  none,
  invalid,
  expired,
  forbidden,
  network,
  limited,
  codeInvalid,
  sent,
  completed,
  storage,
  pushCleanup,
}

class AuthController extends ChangeNotifier {
  AuthController(this.client, this.store)
    : auth = AuthApi(client),
      access = AccessApi(client);
  final ApiClient client;
  final TokenStore store;
  final AuthApi auth;
  final AccessApi access;
  MemberProfile? member;
  bool busy = false;
  AuthMessage message = AuthMessage.none;
  String? _refresh;
  int _generation = 0;
  bool _disposed = false;
  Future<void>? _refreshing;
  Future<void> _vaultQueue = Future.value();
  Future<void> Function()? onSigningOut;
  Future<void> Function(bool discard)? onPrivateStateClearing;
  int get sessionGeneration => _generation;
  String? notificationIntent;
  String? notificationActor;
  void rememberNotification(String id) {
    notificationIntent = id;
    notificationActor = member?.memberId;
  }

  void consumeNotification(String id) {
    if (notificationIntent == id) {
      notificationIntent = null;
      notificationActor = null;
    }
  }

  bool _pushCleanupFailed = false;
  static const _timeout = Duration(seconds: 12);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _vault(Future<void> Function() action) {
    final next = _vaultQueue.then((_) => action());
    _vaultQueue = next.catchError((Object _) {});
    return next;
  }

  Future<void> _accept(AccessTokenResponse? tokens, int generation) async {
    if (generation != _generation || _disposed) return;
    if (tokens == null ||
        tokens.accessToken.isEmpty ||
        tokens.refreshToken.isEmpty) {
      throw const FormatException();
    }
    // The access token stays in memory. Never persist passwords or profile data.
    await _vault(() async {
      if (generation == _generation && !_disposed) {
        await store.write(tokens.refreshToken);
      }
    });
    if (generation != _generation || _disposed) return;
    _refresh = tokens.refreshToken;
    client.addDefaultHeader('Authorization', 'Bearer ${tokens.accessToken}');
  }

  Future<void> _clear({bool discardPrivate = false}) async {
    _generation++;
    var privateStorageFailed = false;
    if (discardPrivate) {
      notificationIntent = null;
      notificationActor = null;
    }
    try {
      await onPrivateStateClearing?.call(discardPrivate);
    } catch (_) {
      privateStorageFailed = true;
    }
    _pushCleanupFailed = false;
    final cleanup = onSigningOut;
    if (cleanup != null) {
      try {
        await cleanup().timeout(const Duration(seconds: 10));
      } catch (_) {
        _pushCleanupFailed = true;
      }
    }
    member = null;
    _refresh = null;
    client.defaultHeaderMap.remove('Authorization');
    await _vault(store.clear);
    if (privateStorageFailed) throw StateError('private_state_cleanup');
  }

  Future<void> _failure(Object error, {bool login = false}) async {
    final status = error is ApiException ? error.code : 0;
    message = status == 401
        ? (login ? AuthMessage.invalid : AuthMessage.expired)
        : status == 403
        ? AuthMessage.forbidden
        : status == 429
        ? AuthMessage.limited
        : AuthMessage.network;
    try {
      await _clear();
    } catch (_) {
      message = AuthMessage.storage;
    }
  }

  Future<void> login(String email, String password) async {
    if (busy) return;
    busy = true;
    message = AuthMessage.none;
    _notify();
    try {
      await _clear();
      final generation = _generation;
      await _accept(
        await auth
            .loginToken(Credentials(email: email, password: password))
            .timeout(_timeout),
        generation,
      );
      final profile = await access.getCurrentMember().timeout(_timeout);
      if (generation == _generation) member = profile;
    } catch (error) {
      await _failure(error, login: true);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> restore() async {
    if (busy) return;
    busy = true;
    message = AuthMessage.none;
    final generation = _generation;
    _notify();
    try {
      final stored = await store.read();
      if (generation != _generation) return;
      _refresh = stored;
      if (stored != null) {
        await _renew(generation);
        final profile = await access.getCurrentMember().timeout(_timeout);
        if (generation == _generation) member = profile;
      }
    } catch (error) {
      if (generation == _generation) await _failure(error);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> _renew(int generation) =>
      _refreshing ??= _renewOnce(generation).whenComplete(() {
        _refreshing = null;
      });
  Future<void> _renewOnce(int generation) async {
    final refresh = _refresh;
    if (refresh == null) throw ApiException(401, '');
    await _accept(
      await auth
          .refreshSession(RefreshRequest(refreshToken: refresh))
          .timeout(_timeout),
      generation,
    );
  }

  // Only this idempotent profile read retries once. No mutation retry or refresh loop.
  Future<void> check() async {
    if (busy) return;
    busy = true;
    final generation = _generation;
    _notify();
    try {
      MemberProfile? profile;
      try {
        profile = await access.getCurrentMember().timeout(_timeout);
      } on ApiException catch (error) {
        if (error.code != 401) rethrow;
        await _renew(generation);
        if (generation != _generation) return;
        profile = await access.getCurrentMember().timeout(_timeout);
      }
      if (generation == _generation) {
        member = profile;
        message = AuthMessage.none;
      }
    } catch (error) {
      if (generation == _generation) await _failure(error);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> logout() async {
    // Built-in bearer signout does not revoke copied tokens. Local removal works offline.
    try {
      await _clear(discardPrivate: true);
      message = _pushCleanupFailed ? AuthMessage.pushCleanup : AuthMessage.none;
    } catch (_) {
      message = AuthMessage.storage;
    }
    _notify();
  }

  // Notification reads are idempotent. Refresh once and discard results from an older account/session.
  Future<T> readAuthenticated<T>(Future<T> Function() action) async {
    final generation = _generation;
    try {
      T result;
      try {
        result = await action().timeout(_timeout);
      } on ApiException catch (error) {
        if (error.code != 401) rethrow;
        await _renew(generation);
        if (generation != _generation || _disposed) throw ApiException(401, '');
        result = await action().timeout(_timeout);
      }
      if (generation != _generation || _disposed) throw ApiException(401, '');
      return result;
    } catch (error) {
      if (generation == _generation &&
          error is ApiException &&
          (error.code == 401 || error.code == 403)) {
        await _failure(error);
        _notify();
      }
      rethrow;
    }
  }

  Future<bool> account(
    String mode,
    String email,
    String code,
    String password,
  ) async {
    if (busy) return false;
    busy = true;
    _notify();
    try {
      if (mode == 'activation') {
        await auth
            .requestActivation(EmailRequest(email: email))
            .timeout(_timeout);
      } else if (mode == 'recovery') {
        await auth
            .requestRecovery(EmailRequest(email: email))
            .timeout(_timeout);
      } else {
        final request = CompleteAccountRequest(
          email: email,
          code: code,
          password: password,
        );
        if (mode == 'activate') {
          await auth.activateAccount(request).timeout(_timeout);
        } else {
          await auth.resetPassword(request).timeout(_timeout);
        }
      }
      message = mode == 'activation' || mode == 'recovery'
          ? AuthMessage.sent
          : AuthMessage.completed;
      return true;
    } catch (error) {
      final status = error is ApiException ? error.code : 0;
      message = status == 429
          ? AuthMessage.limited
          : status == 0 || status >= 500
          ? AuthMessage.network
          : AuthMessage.codeInvalid;
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    client.client.close();
    super.dispose();
  }
}
