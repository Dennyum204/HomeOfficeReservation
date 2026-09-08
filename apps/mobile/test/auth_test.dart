import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/auth/auth_controller.dart';
import 'package:homeoffice_mobile/features/auth/token_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class MemoryStore implements TokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String refresh) async {
    value = refresh;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

http.Response json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);
final tokens = {
  'accessToken': 'simulated-access',
  'refreshToken': 'simulated-refresh',
  'expiresIn': 900,
  'tokenType': 'Bearer',
};
final profile = {
  'active': true,
  'displayName': 'Synthetic',
  'email': 'employee@test.example',
  'isEmployee': true,
  'isManager': false,
  'isAccountAdministrator': false,
  'memberId': 'member',
  'organizationId': 'org',
  'organizationName': 'Synthetic',
};
AuthController controller(
  MemoryStore store,
  Future<http.Response> Function(http.Request) handler,
) {
  final client = ApiClient(basePath: 'http://localhost');
  client.client.close();
  client.client = MockClient(handler);
  return AuthController(client, store);
}

void main() {
  test('simulated 401 refreshes only once and erases data when the retry also fails', () async {
    var refreshes = 0;
    var expired = false;
    final store = MemoryStore();
    final c = controller(store, (r) async {
      if (r.url.path.endsWith('/login')) return json(tokens);
      if (r.url.path.endsWith('/refresh')) {
        refreshes++;
        return json(tokens);
      }
      return expired ? json({}, 401) : json(profile);
    });
    addTearDown(c.dispose);
    await c.login('employee@test.example', 'simulated-password');
    expect(c.member != null, isTrue);
    expired = true;
    await c.check();
    expect(refreshes, 1);
    expect(c.member, isNull);
    expect(store.value, isNull);
    expect(c.message, AuthMessage.expired);
  });
  test(
    'simulated revoked refresh cannot restore and logout is available offline',
    () async {
      final store = MemoryStore()..value = 'simulated-refresh';
      final c = controller(store, (_) async => json({}, 401));
      addTearDown(c.dispose);
      await c.restore();
      expect(c.member, isNull);
      expect(store.value, isNull);
      expect(c.message, AuthMessage.expired);
      await c.logout();
      expect(c.message, AuthMessage.none);
    },
  );
  test('an in-flight refresh cannot resurrect account data or credentials after logout', () async {
    final store = MemoryStore()..value = 'simulated-refresh';
    final pending = Completer<http.Response>();
    final requested = Completer<void>();
    final c = controller(store, (r) async {
      if (r.url.path.endsWith('/refresh')) {
        requested.complete();
        return pending.future;
      }
      return json(profile);
    });
    addTearDown(c.dispose);
    final restoration = c.restore();
    await requested.future;
    await c.logout();
    pending.complete(json(tokens));
    await restoration;
    expect(c.member, isNull);
    expect(store.value, isNull);
    expect(c.client.defaultHeaderMap.containsKey('Authorization'), isFalse);
  });
  test(
    'current disabled membership clears a still-valid simulated access token',
    () async {
      final store = MemoryStore();
      var disabled = false;
      final c = controller(
        store,
        (r) async => r.url.path.endsWith('/login')
            ? json(tokens)
            : disabled
            ? json({}, 403)
            : json(profile),
      );
      addTearDown(c.dispose);
      await c.login('employee@test.example', 'simulated-password');
      disabled = true;
      await c.check();
      expect(c.member, isNull);
      expect(store.value, isNull);
      expect(c.message, AuthMessage.forbidden);
    },
  );
}
