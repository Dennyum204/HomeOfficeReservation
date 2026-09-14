import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_mobile/features/notifications/notification_alerts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(
    () => messenger.setMockMethodCallHandler(NotificationAlerts.channel, null),
  );
  test('alert bridge transmits only the opaque inbox identifier', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(NotificationAlerts.channel, (
      call,
    ) async {
      calls.add(call);
      return null;
    });
    await NotificationAlerts.show('00000000-0000-4000-8000-000000000001');
    expect(calls.single.method, 'show');
    expect(calls.single.arguments, '00000000-0000-4000-8000-000000000001');
  });
  test(
    'denied or unavailable native display does not break the inbox callback',
    () async {
      messenger.setMockMethodCallHandler(
        NotificationAlerts.channel,
        (_) async => throw PlatformException(code: 'denied'),
      );
      await expectLater(
        NotificationAlerts.show('00000000-0000-4000-8000-000000000001'),
        completes,
      );
      messenger.setMockMethodCallHandler(
        NotificationAlerts.channel,
        (_) async => throw MissingPluginException(),
      );
      await expectLater(
        NotificationAlerts.show('00000000-0000-4000-8000-000000000001'),
        completes,
      );
    },
  );
}
