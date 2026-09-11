import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:http/http.dart' as http;
import 'package:homeoffice_mobile/features/notifications/push_gateway.dart';
import 'package:homeoffice_mobile/features/notifications/push_coordinator.dart';
import 'package:homeoffice_mobile/features/notifications/inbox_controller.dart';
import 'package:homeoffice_mobile/features/notifications/notification_repository.dart';
import 'package:homeoffice_mobile/features/auth/auth_controller.dart';

import 'auth_test.dart' as fixture;

class BindingStore implements PushBindingStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String text) async {
    value = text;
  }
}

class FakeGateway implements PushGateway {
  bool allowed = false;
  int resets = 0;
  Object? registrationError;
  String fid = 'cSyntheticAddress12345';
  final opens = StreamController<String>.broadcast();
  final messages = StreamController<String>.broadcast();
  final rotations = StreamController<String>.broadcast();
  @override
  bool get configured => true;
  @override
  Stream<String> get opened => opens.stream;
  @override
  Stream<String> get foreground => messages.stream;
  @override
  Stream<String> get rotated => rotations.stream;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> permission() async => allowed;
  @override
  Future<bool> permissionGranted() async => allowed;
  @override
  Future<String> address() async {
    if (registrationError case final error?) throw error;
    return fid;
  }

  @override
  Future<void> reset() async {
    resets++;
  }

  @override
  void dispose() {
    unawaited(opens.close());
    unawaited(messages.close());
    unawaited(rotations.close());
  }
}

void main() {
  test('disposed push initialization never starts a new capabilities request after storage cleanup', () async {
    var requests = 0;
    final auth = fixture.controller(fixture.MemoryStore(), (_) async {
      requests++;
      return fixture.json({'provider': 'Fcm'});
    })..member = fixtureMember();
    final stored = Completer<String?>();
    final push = PushCoordinator(
      auth,
      FakeGateway(),
      DelayedBinding(stored),
      onOpen: (_) {},
      onForeground: (_) {},
    );
    final initializing = push.initialize();
    push.dispose();
    stored.complete(null);
    await initializing;
    expect(requests, 0);
    auth.dispose();
  });
  test(
    'unconfigured device does not query push capabilities or report enabled',
    () async {
      var requests = 0;
      final auth = fixture.controller(fixture.MemoryStore(), (_) async {
        requests++;
        return fixture.json({'provider': 'Fcm'});
      })..member = fixtureMember();
      final push = PushCoordinator(
        auth,
        UnconfiguredGateway(),
        BindingStore(),
        onOpen: (_) {},
        onForeground: (_) {},
      );
      await push.initialize();
      expect(requests, 0);
      expect(push.status, PushStatus.unavailable);
      expect(push.enabled, isFalse);
      push.dispose();
      auth.dispose();
    },
  );
  test(
    'simulated registration failure can be retried without disabling consent',
    () async {
      var registrations = 0;
      final auth = fixture.controller(fixture.MemoryStore(), (r) async {
        if (r.method == 'PUT') {
          registrations++;
          final body = jsonDecode(r.body) as Map<String, dynamic>;
          return fixture.json({
            'installationId': body['installationId'],
            'provider': 'Fcm',
            'version': 1,
            'expiresAt': '2026-09-10T12:00:00Z',
          });
        }
        return fixture.json({'provider': 'Fcm'});
      })..member = fixtureMember();
      final gateway = FakeGateway()
        ..allowed = true
        ..registrationError = StateError('synthetic provider failure');
      final push = PushCoordinator(
        auth,
        gateway,
        BindingStore(),
        onOpen: (_) {},
        onForeground: (_) {},
      );
      addTearDown(() {
        push.dispose();
        auth.dispose();
      });
      await push.initialize();
      await push.enable();
      expect(push.status, PushStatus.error);
      expect(push.enabled, isTrue);
      expect(registrations, 0);
      gateway.registrationError = null;
      await push.synchronize();
      expect(push.status, PushStatus.enabled);
      expect(registrations, 1);
      expect(gateway.resets, 0);
    },
  );
  test('simulated delayed device registration and old push callback cannot restore a logged-out account', () async {
    final pending = Completer<http.Response>();
    final requested = Completer<Map<String, dynamic>>();
    var removed = false;
    var opened = false;
    final auth = fixture.controller(fixture.MemoryStore(), (r) async {
      if (r.method == 'PUT') {
        requested.complete(jsonDecode(r.body) as Map<String, dynamic>);
        return pending.future;
      }
      if (r.method == 'DELETE') {
        removed = true;
        return fixture.json({}, 204);
      }
      return fixture.json({'provider': 'Fcm'});
    })..member = fixtureMember();
    final store = BindingStore();
    final gateway = FakeGateway()..allowed = true;
    final push = PushCoordinator(
      auth,
      gateway,
      store,
      onOpen: (_) {
        opened = true;
      },
      onForeground: (_) {},
    );
    addTearDown(() {
      push.dispose();
      auth.dispose();
    });
    await push.initialize();
    final enabling = push.enable();
    final body = await requested.future;
    await auth.logout();
    expect(removed, isTrue);
    pending.complete(
      fixture.json({
        'installationId': body['installationId'],
        'provider': 'Fcm',
        'version': 1,
        'expiresAt': '2026-09-10T12:00:00Z',
      }),
    );
    await enabling;
    gateway.opens.add('00000000-0000-0000-0000-000000000007');
    await Future<void>.delayed(Duration.zero);
    expect(opened, isFalse);
    expect(push.enabled, isFalse);
    expect(auth.member, isNull);
    expect((jsonDecode(store.value!) as Map)['installation'], isNull);
  });
  test('push links accept only schema and notification UUID, never an action or URL', () {
    const id = '00000000-0000-0000-0000-000000000007';
    expect(notificationLink({'schema': '1', 'notificationId': id}), id);
    expect(notificationLink({'schema': '2', 'notificationId': id}), isNull);
    expect(
      notificationLink({
        'schema': '1',
        'notificationId': 'https://example.invalid/approve',
      }),
      isNull,
    );
    expect(
      notificationLink({'schema': '1', 'notificationId': '../approve'}),
      isNull,
    );
  });
  test('simulated permission refusal keeps inbox usable; rotation versions and logout removes binding', () async {
    final registrations = <Map<String, dynamic>>[];
    final removals = <String>[];
    final auth = fixture.controller(fixture.MemoryStore(), (r) async {
      if (r.url.path.endsWith('/capabilities')) {
        return fixture.json({'provider': 'Fcm'});
      }
      if (r.method == 'PUT') {
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        registrations.add(body);
        return fixture.json({
          'installationId': body['installationId'],
          'provider': 'Fcm',
          'version': registrations.length,
          'expiresAt': '2026-09-10T12:00:00Z',
        });
      }
      if (r.method == 'DELETE') {
        removals.add(r.url.path);
        return fixture.json({}, 204);
      }
      if (r.url.path.endsWith('/unread-count')) {
        return fixture.json({'unreadCount': 3});
      }
      return fixture.json(fixture.profile);
    })..member = fixtureMember();
    final gateway = FakeGateway();
    final store = BindingStore();
    final push = PushCoordinator(
      auth,
      gateway,
      store,
      onOpen: (_) {},
      onForeground: (_) {},
    );
    addTearDown(() {
      push.dispose();
      auth.dispose();
    });
    await push.initialize();
    await push.enable();
    expect(push.status, PushStatus.denied);
    expect(registrations, isEmpty);
    expect(await NotificationRepository(auth).count(), 3);
    gateway.allowed = true;
    await push.enable();
    expect(push.status, PushStatus.enabled);
    expect(registrations.single['expectedVersion'], isNull);
    final rotated = Completer<void>();
    final resumed = Completer<void>();
    push.addListener(() {
      if (push.status != PushStatus.enabled) return;
      if (registrations.length == 2 && !rotated.isCompleted) rotated.complete();
      if (registrations.length == 3 && !resumed.isCompleted) resumed.complete();
    });
    gateway.fid = 'cRotatedAddress1234567';
    gateway.rotations.add(gateway.fid);
    await rotated.future.timeout(const Duration(seconds: 2));
    expect(registrations.last['expectedVersion'], 1);
    expect(registrations.last['address'], gateway.fid);
    expect(
      registrations.last['installationId'],
      registrations.first['installationId'],
    );
    // A FID change without a native callback is picked up on foreground entry.
    push.activity(false);
    gateway.fid = 'cForegroundAddress1234';
    push.activity(true);
    await resumed.future.timeout(const Duration(seconds: 2));
    expect(registrations.last['expectedVersion'], 2);
    expect(registrations.last['address'], gateway.fid);
    expect(
      registrations.last['installationId'],
      registrations.first['installationId'],
    );
    await auth.logout();
    expect(
      removals.single,
      endsWith(registrations.first['installationId'] as String),
    );
    expect(gateway.resets, 1);
    expect(auth.member, isNull);
    expect((jsonDecode(store.value!) as Map)['enabled'], false);
  });
  test('simulated offline logout preserves a cleanup record and reports uncertainty', () async {
    final auth = fixture.controller(fixture.MemoryStore(), (r) async {
      if (r.method == 'DELETE') throw StateError('synthetic offline');
      return fixture.json({'provider': 'Disabled'});
    })..member = fixtureMember();
    final store = BindingStore()
      ..value = jsonEncode({
        'actor': 'member',
        'installation': '00000000-0000-0000-0000-000000000007',
        'version': 1,
        'enabled': true,
      });
    final push = PushCoordinator(
      auth,
      FakeGateway(),
      store,
      onOpen: (_) {},
      onForeground: (_) {},
    );
    addTearDown(() {
      push.dispose();
      auth.dispose();
    });
    await push.initialize();
    await auth.logout();
    expect(auth.member, isNull);
    expect(auth.message, AuthMessage.pushCleanup);
    expect((jsonDecode(store.value!) as Map)['pendingRemoval'], hasLength(1));
  });
  test(
    'in-flight simulated inbox read cannot repopulate a disposed account',
    () async {
      final pending = Completer<int>();
      final repository = DelayedRepository(pending);
      final inbox = InboxController(repository);
      final loading = inbox.refresh();
      inbox.dispose();
      pending.complete(99);
      await loading;
      expect(inbox.unreadCount, 0);
      repository.auth.dispose();
    },
  );
}

// All provider/HTTP responses in this file are simulations, not FCM delivery evidence.
MemberProfile fixtureMember() => MemberProfile.fromJson(fixture.profile)!;

class DelayedRepository extends NotificationRepository {
  DelayedRepository(this.pending)
    : super(
        fixture.controller(
          fixture.MemoryStore(),
          (_) async => fixture.json({}),
        ),
      );
  final Completer<int> pending;
  @override
  Future<int> count() => pending.future;
}

class DelayedBinding extends BindingStore {
  DelayedBinding(this.pending);
  final Completer<String?> pending;
  @override
  Future<String?> read() => pending.future;
}

class UnconfiguredGateway extends FakeGateway {
  @override
  bool get configured => false;
}
