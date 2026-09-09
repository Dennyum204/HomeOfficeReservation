import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/config/api_settings.dart';
import 'package:homeoffice_mobile/features/auth/auth_controller.dart';
import 'package:homeoffice_mobile/features/auth/auth_screen.dart';
import 'package:homeoffice_mobile/features/notifications/push_coordinator.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';
import 'package:homeoffice_mobile/main.dart' as app;

// Manual, explicitly configured live test. Never part of core CI or default setup.
// Permission must already have been granted by the test-device owner.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'live FCM reconnect and account switching revoke previous bindings',
    (tester) async {
      expect(Platform.isAndroid, isTrue);
      expect(const bool.fromEnvironment('FCM_ENABLED'), isTrue);
      const employeeEmail = String.fromEnvironment('TEST_EMAIL');
      const employeePassword = String.fromEnvironment('TEST_PASSWORD');
      const managerEmail = String.fromEnvironment('TEST_MANAGER_EMAIL');
      const managerPassword = String.fromEnvironment('TEST_MANAGER_PASSWORD');
      expect(
        [
          employeeEmail,
          employeePassword,
          managerEmail,
          managerPassword,
        ].every((value) => value.isNotEmpty),
        isTrue,
        reason: 'Use the authorized private synthetic account configuration.',
      );

      Future<void> waitFor(String text) async {
        for (var i = 0; i < 80 && find.text(text).evaluate().isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(find.text(text), findsOneWidget);
      }

      Future<void> tap(String text) async {
        final control = find.text(text);
        await tester.ensureVisible(control);
        await tester.pumpAndSettle();
        await tester.tap(control);
        await tester.pump(const Duration(milliseconds: 500));
      }

      Future<void> settings() async {
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();
      }

      Future<void> login(String email, String password) async {
        await tester.enterText(find.byKey(const Key('email')), email);
        await tester.enterText(find.byKey(const Key('password')), password);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('submit')));
        await tester.tap(find.byKey(const Key('submit')));
        await waitFor('Terminar sessão');
      }

      AuthController auth() =>
          tester.widget<AuthScreen>(find.byType(AuthScreen)).controller;
      final bindingStore = SecurePushBindingStore(ApiSettings.baseUrl);
      Future<Map<String, dynamic>> binding() async =>
          jsonDecode((await bindingStore.read())!) as Map<String, dynamic>;
      const registered =
          'Dispositivo registado. A entrega depende da ligação e das definições do Android.';
      const off = 'Alertas desativados neste dispositivo.';

      app.main();
      await tester.pumpAndSettle();
      for (var i = 0; i < 30 && auth().busy; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      if (auth().member == null) await login(employeeEmail, employeePassword);
      await waitFor('Terminar sessão');
      expect(
        auth().member!.isEmployee,
        isTrue,
        reason: 'Start with the selected test employee signed in.',
      );
      await settings();
      for (var i = 0; i < 40; i++) {
        final status = tester
            .widget<WorkspaceScreen>(find.byType(WorkspaceScreen))
            .push!
            .status;
        if (status == PushStatus.off || status == PushStatus.enabled) break;
        await tester.pump(const Duration(milliseconds: 500));
      }
      // Let the normal entrypoint initialize Firebase. Pre-initializing here
      // masks failures when the SDK starts with a cold installation cache.
      expect(
        (await FirebaseMessaging.instance.getNotificationSettings())
            .authorizationStatus,
        AuthorizationStatus.authorized,
        reason: 'The owner must grant Android permission before this test.',
      );
      if (find.text('Ativar alertas neste dispositivo').evaluate().isNotEmpty) {
        await tap('Ativar alertas neste dispositivo');
      }
      await waitFor(registered);
      final first = await binding();
      final employee = auth().member!.memberId;
      final notification = (await auth().readAuthenticated(
        () => NotificationsApi(auth().client).listNotifications(limit: 1),
      ))!.items.first;
      await tap('Desativar alertas');
      await waitFor(off);
      expect((await binding())['installation'], isNull);
      await expectLater(
        NotificationsApi(auth().client).registerPushDevice(
          DeviceRegistrationInput(
            installationId: first['installation'] as String,
            provider: PushProvider.fcm,
            address: 'cSyntheticAddress12345',
            expectedVersion: first['version'] as int,
          ),
        ),
        throwsA(
          isA<ApiException>().having((error) => error.code, 'status', 409),
        ),
      );
      await tap('Ativar alertas neste dispositivo');
      await waitFor(registered);
      final second = await binding();
      expect(second['installation'], isNot(first['installation']));
      await tap('Terminar sessão');
      await waitFor('Entre no seu espaço');
      expect((await binding())['enabled'], isFalse);
      expect((await binding())['installation'], isNull);

      await login(managerEmail, managerPassword);
      expect(auth().member!.isManager, isTrue);
      expect(auth().member!.memberId, isNot(employee));
      await expectLater(
        NotificationsApi(auth().client).getNotification(notification.id),
        throwsA(
          isA<ApiException>().having((error) => error.code, 'status', 404),
        ),
      );
      await settings();
      await waitFor(off);
      await tap('Ativar alertas neste dispositivo');
      await waitFor(registered);
      final manager = await binding();
      expect(manager['installation'], isNot(second['installation']));
      await tap('Terminar sessão');
      await waitFor('Entre no seu espaço');
      expect((await binding())['installation'], isNull);

      await login(employeeEmail, employeePassword);
      expect(auth().member!.memberId, employee);
      await settings();
      await waitFor(off);
      await tap('Ativar alertas neste dispositivo');
      await waitFor(registered);
      final restored = await binding();
      expect(restored['installation'], isNot(manager['installation']));
      expect(restored['actor'], employee);
      // Leave the selected employee signed in. Reinstall the normal entrypoint after
      // the test; never distribute the private-account test bundle.
    },
  );
}
