import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:homeoffice_api/api.dart';

import '../auth/auth_controller.dart';
import 'push_gateway.dart';

abstract class PushBindingStore {
  Future<String?> read();
  Future<void> write(String value);
}

class SecurePushBindingStore implements PushBindingStore {
  SecurePushBindingStore(String origin) : key = 'HomeOffice.Push.$origin';
  final String key;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final Map<String, Future<void>> _queues = {};
  @override
  Future<String?> read() async {
    await _queues[key];
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String value) {
    final next = (_queues[key] ?? Future<void>.value()).then(
      (_) => _storage.write(key: key, value: value),
    );
    _queues[key] = next.catchError((Object _) {});
    return next;
  }
}

enum PushStatus { unavailable, off, enabled, denied, error, busy }

class PushCoordinator extends ChangeNotifier {
  PushCoordinator(
    this.auth,
    this.gateway,
    this.store, {
    required this.onOpen,
    required this.onForeground,
  }) : api = NotificationsApi(auth.client),
       _actor = auth.member!.memberId {
    auth.onSigningOut = signOut;
    _subscriptions.add(
      gateway.opened.listen((id) {
        if (_current(_epoch)) {
          onOpen(id);
          unawaited(_receipt(id));
        }
      }),
    );
    _subscriptions.add(
      gateway.foreground.listen((id) {
        if (_current(_epoch)) {
          onForeground(id);
          unawaited(_receipt(id));
        }
      }),
    );
    _subscriptions.add(
      gateway.rotated.listen((_) {
        if (enabled) unawaited(synchronize());
      }),
    );
  }
  final AuthController auth;
  final PushGateway gateway;
  final PushBindingStore store;
  final NotificationsApi api;
  final void Function(String) onOpen;
  final void Function(String) onForeground;
  final List<StreamSubscription<String>> _subscriptions = [];
  PushStatus status = PushStatus.unavailable;
  bool enabled = false;
  bool _disposed = false;
  bool _visible = true;
  int _epoch = 0;
  String? _installation;
  int? _version;
  final List<Map<String, String>> _pendingRemoval = [];
  Future<void>? _registering;
  Timer? _renewal;
  final String _actor;
  bool _current(int epoch) =>
      !_disposed && _epoch == epoch && auth.member?.memberId == _actor;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _diagnostic(String stage, Object error) {
    if (kDebugMode) {
      // Only fixed stages, exception types and HTTP status; never messages,
      // addresses, response bodies or authentication/configuration values.
      final status = error is ApiException ? error.code : 0;
      final native =
          error is PlatformException &&
              const {
                'registration_failed',
                'removal_failed',
                'configuration_failed',
              }.contains(error.code)
          ? error.code
          : 'none';
      final detail =
          error is PlatformException &&
              error.details is String &&
              RegExp(r'^[A-Za-z]+Exception$').hasMatch(error.details as String)
          ? error.details as String
          : 'none';
      debugPrint(
        'Push $stage failed (${error.runtimeType}; HTTP $status; native $native/$detail).',
      );
    }
  }

  String _newId() {
    final random = Random.secure();
    final value = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-${value.substring(12, 16)}-${value.substring(16, 20)}-${value.substring(20)}';
  }

  Future<void> _save() async {
    if (_disposed) return;
    await store.write(
      jsonEncode({
        'actor': _actor,
        'installation': _installation,
        'version': _version,
        'enabled': enabled,
        'pendingRemoval': _pendingRemoval,
      }),
    );
  }

  Future<void> initialize() async {
    final epoch = _epoch;
    try {
      final text = await store.read();
      if (!_current(epoch)) return;
      final saved = text == null
          ? <String, dynamic>{}
          : jsonDecode(text) as Map<String, dynamic>;
      for (final value in (saved['pendingRemoval'] as List? ?? [])) {
        _pendingRemoval.add(Map<String, String>.from(value as Map));
      }
      if (saved['actor'] == _actor) {
        _installation = saved['installation'] as String?;
        _version = saved['version'] as int?;
        enabled = saved['enabled'] == true;
      } else if (saved['installation'] != null && saved['actor'] != null) {
        _pendingRemoval.add({
          'actor': saved['actor'] as String,
          'installation': saved['installation'] as String,
        });
      }
      await _removePending();
      final capabilities = await auth.readAuthenticated(
        () => api.getNotificationCapabilities(),
      );
      if (!_current(epoch)) return;
      if (!gateway.configured || capabilities?.provider != PushProvider.fcm) {
        enabled = false;
        status = PushStatus.unavailable;
        _notify();
        return;
      }
      await gateway.initialize().timeout(const Duration(seconds: 12));
      if (!_current(epoch)) return;
      status = PushStatus.off;
      if (enabled) await synchronize();
      _schedule();
      _notify();
    } catch (error) {
      _diagnostic('initialize', error);
      if (_current(epoch)) {
        enabled = false;
        status = PushStatus.error;
        _notify();
      }
    }
  }

  Future<void> enable() async {
    if (_disposed ||
        status == PushStatus.unavailable ||
        status == PushStatus.busy) {
      return;
    }
    final epoch = _epoch;
    status = PushStatus.busy;
    _notify();
    try {
      await gateway.initialize();
      if (!await gateway.permission() || !_current(epoch)) {
        if (_current(epoch)) {
          status = PushStatus.denied;
          _notify();
        }
        return;
      }
      // A previous account's offline logout must reset the provider identity before a new binding.
      if (_pendingRemoval.isNotEmpty) {
        await gateway.reset().timeout(const Duration(seconds: 8));
      }
      if (!_current(epoch)) return;
      enabled = true;
      await synchronize();
    } catch (_) {
      if (_current(epoch)) {
        enabled = false;
        status = PushStatus.error;
        _notify();
      }
    }
  }

  Future<void> synchronize() =>
      _registering ??= _synchronize().whenComplete(() {
        _registering = null;
      });
  Future<void> _synchronize() async {
    final epoch = _epoch;
    if (!enabled || !_current(epoch)) return;
    status = PushStatus.busy;
    _notify();
    var stage = 'permission';
    try {
      if (!await gateway.permissionGranted()) {
        await disable();
        status = PushStatus.denied;
        _notify();
        return;
      }
      stage = 'provider-registration';
      final address = await gateway.address().timeout(
        const Duration(seconds: 12),
      );
      if (!_current(epoch) || !enabled) return;
      stage = 'session';
      // A read refreshes the framework session, but cannot replay registration automatically.
      await auth.readAuthenticated(() => api.getNotificationCapabilities());
      if (!_current(epoch)) return;
      _installation ??= _newId();
      await _save();
      stage = 'server-registration';
      final response = await api
          .registerPushDevice(
            DeviceRegistrationInput(
              installationId: _installation!,
              provider: PushProvider.fcm,
              address: address,
              expectedVersion: _version,
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (!_current(epoch)) return;
      _version = response!.version;
      status = PushStatus.enabled;
      await _save();
      _notify();
    } catch (error) {
      _diagnostic(stage, error);
      if (_current(epoch)) {
        status = PushStatus.error;
        _notify();
      }
    }
  }

  Future<void> _removePending() async {
    if (auth.member?.memberId != _actor || _disposed) return;
    for (final entry in [..._pendingRemoval]) {
      if (entry['actor'] != _actor) continue;
      try {
        await api
            .removePushDevice(entry['installation']!)
            .timeout(const Duration(seconds: 4));
        if (!_disposed && auth.member?.memberId == _actor) {
          _pendingRemoval.remove(entry);
        }
      } catch (_) {
        /* Retry after reconnecting as the same account; never retain old auth credentials. */
      }
    }
    await _save();
  }

  Future<void> _receipt(String id) async {
    if (!enabled || _installation == null || auth.member == null) return;
    try {
      await auth.readAuthenticated(() => api.getNotification(id));
      if (!enabled || _installation == null || auth.member == null) return;
      await api
          .reportNotificationDeviceReceipt(
            id,
            DeviceReceiptInput(installationId: _installation!),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      /* A receipt is best effort and never a business acknowledgement. */
    }
  }

  Future<void> disable() async {
    _epoch++;
    enabled = false;
    _renewal?.cancel();
    final installation = _installation;
    final actor = auth.member?.memberId;
    _installation = null;
    _version = null;
    if (installation != null &&
        actor != null &&
        !_pendingRemoval.any((x) => x['installation'] == installation)) {
      _pendingRemoval.add({'actor': actor, 'installation': installation});
    }
    await _save();
    await _removePending();
    try {
      await gateway.reset().timeout(const Duration(seconds: 4));
    } catch (_) {
      status = PushStatus.error;
      _notify();
      rethrow;
    }
    status = PushStatus.off;
    _notify();
    if (_pendingRemoval.any((x) => x['actor'] == actor)) {
      throw StateError('push_removal_pending');
    }
  }

  Future<void> signOut() async {
    _epoch++;
    enabled = false;
    _renewal?.cancel();
    // Wait briefly for an in-flight registration, then revoke the known installation. Offline cleanup remains durable.
    // Server removal writes a revocation tombstone, so even a delayed first registration is denied.
    await disable();
  }

  void activity(bool visible) {
    _visible = visible;
    _renewal?.cancel();
    if (visible) {
      if (enabled) unawaited(synchronize());
      _schedule();
    }
  }

  void _schedule() {
    _renewal?.cancel();
    if (!_disposed && _visible) {
      _renewal = Timer(const Duration(minutes: 15), () {
        if (enabled) unawaited(synchronize());
        _schedule();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _renewal?.cancel();
    if (auth.onSigningOut == signOut) auth.onSigningOut = null;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    gateway.dispose();
    super.dispose();
  }
}
