import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:homeoffice_mobile/config/api_settings.dart';
import 'package:homeoffice_mobile/features/auth/token_store.dart';

void main() {
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
    await SecureTokenStore(ApiSettings.baseUrl).clear();
    app.main();
    await tester.pumpAndSettle();
    Future<void> login(String address, String secret) async {
      await tester.enterText(find.byKey(const Key('email')), address);
      await tester.enterText(find.byKey(const Key('password')), secret);
      await tester.ensureVisible(find.byKey(const Key('submit')));
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
      for (
        var i = 0;
        i < 30 && find.text('Terminar sessão').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    await tester.enterText(
      find.byKey(const Key('email')),
      'absent@test.example',
    );
    await tester.enterText(
      find.byKey(const Key('password')),
      'Deliberately-wrong9!',
    );
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();
    for (
      var i = 0;
      i < 30 &&
          find.textContaining('Não foi possível entrar.').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.textContaining('Não foi possível entrar.'), findsOneWidget);
    await login(email, password);
    expect(find.text('Terminar sessão'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Ligação ao serviço'), 250);
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
    // The server used by this test has Development-only access=3s / refresh=8s.
    await Future<void>.delayed(const Duration(seconds: 9));
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
    expect(find.text('Chefia de teste'), findsOneWidget);
    await tester.tap(find.text('Terminar sessão'));
    await tester.pumpAndSettle();
    expect(find.text('Entre no seu espaço'), findsOneWidget);
    expect(find.text('Chefia de teste'), findsNothing);
    expect(await SecureTokenStore(ApiSettings.baseUrl).read() == null, isTrue);
  });
}
