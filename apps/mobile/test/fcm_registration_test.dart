import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_mobile/features/notifications/fcm_registration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('homeoffice/fcm-registration');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<void> registered(Object value) async {
    final done = Completer<void>();
    await messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('registered', value),
      ),
      (_) => done.complete(),
    );
    await done.future;
  }

  test('simulated native FID registration ignores unchanged callbacks and preserves changed IDs', () async {
    const first = 'cSyntheticAddress12345';
    const second = 'dSyntheticAddress12345';
    var current = first;
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return call.method == 'register' ? current : null;
    });
    final registration = FcmRegistration()..initialize();
    final changes = <String>[];
    final subscription = registration.changes.listen(changes.add);
    addTearDown(() async {
      await subscription.cancel();
      registration.dispose();
      messenger.setMockMethodCallHandler(channel, null);
    });

    expect(await registration.register(), first);
    await registered(
      first,
    ); // register() itself also triggers onRegistered in FCM.
    await registered(first);
    await registered('not-a-valid-installation');
    expect(changes, isEmpty);
    await registered(second);
    await registered(second);
    expect(changes, [second]);
    await registration.reset();
    current = second;
    expect(await registration.register(), second);
    await registered(second);
    expect(changes, [second]);
    expect(calls, ['register', 'reset', 'register']);
  });

  test('simulated missing or failed native registration never returns a usable address', () async {
    final registration = FcmRegistration();
    addTearDown(() {
      registration.dispose();
      messenger.setMockMethodCallHandler(channel, null);
    });
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    await expectLater(registration.register(), throwsFormatException);
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'registration_failed'),
    );
    await expectLater(
      registration.register(),
      throwsA(isA<PlatformException>()),
    );
  });
}
