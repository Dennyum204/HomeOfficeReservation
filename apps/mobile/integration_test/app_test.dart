import 'dart:developer' show Service;
import 'dart:io' show Platform, stdout;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:homeoffice_mobile/config/api_settings.dart';
import 'package:homeoffice_mobile/features/auth/token_store.dart';
import 'package:homeoffice_mobile/features/auth/auth_screen.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_repository.dart';
import 'package:homeoffice_api/api.dart';

Future<void> main() async {
  // Only the private iOS CI wrapper enables this test-only diagnostic. Write to
  // the attached stdout descriptor, bypassing Flutter's platform log discovery.
  // The wrapper keeps the debugger capability private and never publishes it.
  if (Platform.isIOS && const bool.fromEnvironment('TEST_IOS_CONSOLE')) {
    stdout.writeln('iOS Dart test entrypoint reached.');
    Uri? address;
    for (var attempt = 0; attempt < 20 && address == null; attempt++) {
      address = (await Service.getInfo().timeout(const Duration(seconds: 2)))
          .serverUri;
      if (address == null) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
    if (address == null ||
        !{'localhost', '127.0.0.1', '::1'}.contains(address.host)) {
      throw StateError('No loopback debug service available to the iOS test.');
    }
    stdout.writeln('Dart VM service is listening on $address');
  }
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native login, secure restoration, expiry, logout and real API', (
    tester,
  ) async {
    const email = String.fromEnvironment('TEST_EMAIL');
    const password = String.fromEnvironment('TEST_PASSWORD');
    expect(
      email.isNotEmpty && password.isNotEmpty,
      isTrue,
      reason: 'Provide the private client-test.json; never skip native auth.',
    );
    final connection = WorkspaceRepository(
      WorkspaceApi(ApiClient(basePath: ApiSettings.baseUrl)),
    );
    try {
      expect((await connection.load()).apiVersion, 'v1');
    } finally {
      connection.dispose();
    }
    await SecureTokenStore(ApiSettings.baseUrl).clear();
    app.main();
    await tester.pumpAndSettle();
    Future<void> submitCredentials(String address, String secret) async {
      await tester.enterText(find.byKey(const Key('email')), address);
      await tester.enterText(find.byKey(const Key('password')), secret);
      // Native IME animations can move the button between text entry and the tap.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
    }

    Future<void> login(String address, String secret) async {
      await submitCredentials(address, secret);
      for (
        var i = 0;
        i < 30 && find.text('Terminar sessão').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    await submitCredentials('absent@test.example', 'Deliberately-wrong9!');
    for (
      var i = 0;
      i < 30 &&
          find.textContaining('Não foi possível entrar.').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(
      find.textContaining('Não foi possível entrar.'),
      findsOneWidget,
      reason:
          'Auth status: ${tester.widget<AuthScreen>(find.byType(AuthScreen)).controller.message.name}',
    );
    await login(email, password);
    expect(find.text('Terminar sessão'), findsOneWidget);
    // Connectivity diagnostics live in Settings; the calendar has its own scroll view.
    await tester.tap(find.text('Definições'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ligação ao serviço'));
    for (
      var i = 0;
      i < 30 && find.text('Serviço ligado').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('Serviço ligado'), findsOneWidget);
    expect(find.text('Europe/Lisbon · Europe/Zurich'), findsOneWidget);
    // Recreate the application/controller; restoration must read the actual platform secure store.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    app.main();
    await tester.pumpAndSettle();
    for (
      var i = 0;
      i < 30 && find.text('Terminar sessão').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('Terminar sessão'), findsOneWidget);
    // The server used by this test has Development-only access=5s / refresh=30s.
    // Android's foreground inbox renews an active session. Pause its lifecycle to exercise real idle expiry.
    if (Platform.isAndroid) {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    }
    await Future<void>.delayed(const Duration(seconds: 31));
    if (Platform.isAndroid) {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }
    await tester.tap(find.text('Verificar sessão'));
    await tester.pumpAndSettle();
    for (
      var i = 0;
      i < 30 &&
          find
              .text('A sessão expirou. Inicie sessão novamente.')
              .evaluate()
              .isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(
      find.text('A sessão expirou. Inicie sessão novamente.'),
      findsOneWidget,
    );
    expect(await SecureTokenStore(ApiSettings.baseUrl).read() == null, isTrue);
    await login(
      const String.fromEnvironment('TEST_MANAGER_EMAIL'),
      const String.fromEnvironment('TEST_MANAGER_PASSWORD'),
    );
    // The calendar also names the selected employee; assert the authenticated
    // identity header rather than assuming the name appears only once on screen.
    expect(
      tester
          .widget<Text>(find.byKey(const Key('authenticated-member-name')))
          .data,
      'Chefia de teste',
    );
    await tester.tap(find.text('Terminar sessão'));
    // Frame settling alone does not await the native secure-storage operation.
    for (
      var i = 0;
      i < 100 && find.text('Entre no seu espaço').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pumpAndSettle();
    expect(find.text('Entre no seu espaço'), findsOneWidget);
    expect(find.text('Chefia de teste'), findsNothing);
    expect(await SecureTokenStore(ApiSettings.baseUrl).read() == null, isTrue);
  });
}
