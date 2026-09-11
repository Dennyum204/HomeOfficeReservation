import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_mobile/features/auth/auth_screen.dart';
import 'package:homeoffice_mobile/l10n/generated/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'auth_test.dart' as fixture;

void main() {
  testWidgets(
    'accepted invitation returns to a usable login form (simulated HTTP)',
    (tester) async {
      const email = 'invite@test.example';
      const password = 'Synthetic-password9!';
      var accepted = false;
      var loginSent = false;
      final controller = fixture.controller(fixture.MemoryStore(), (
        request,
      ) async {
        if (request.url.path.endsWith('/activation/complete')) {
          accepted = true;
          return http.Response('', 204);
        }
        if (request.url.path.endsWith('/token/login')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          loginSent = body['email'] == email && body['password'] == password;
          // Deliberately refuse authentication: this test verifies form submission,
          // while the native suite verifies actual Identity activation and login.
          return fixture.json({}, 401);
        }
        throw StateError('Unexpected request');
      });
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ainda não ativei a conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Já tenho um código'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('email')), email);
      await tester.enterText(find.byKey(const Key('code')), 'synthetic-code');
      await tester.enterText(find.byKey(const Key('password')), password);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
      expect(accepted, isTrue);
      expect(find.text('Entre no seu espaço'), findsOneWidget);
      expect(find.byKey(const Key('code')), findsNothing);
      await tester.enterText(find.byKey(const Key('password')), password);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
      expect(
        tester
                .widget<TextFormField>(find.byKey(const Key('email')))
                .controller!
                .text ==
            email,
        isTrue,
      );
      expect(
        tester
                .widget<TextFormField>(find.byKey(const Key('password')))
                .controller!
                .text ==
            password,
        isTrue,
      );
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
      expect(loginSent, isTrue);
      expect(find.textContaining('Não foi possível entrar.'), findsOneWidget);
    },
  );
}
