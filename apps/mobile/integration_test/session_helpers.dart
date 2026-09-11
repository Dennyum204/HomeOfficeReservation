import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_mobile/features/auth/auth_screen.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';

Future<void> waitForWorkspace(WidgetTester tester) async {
  for (
    var i = 0;
    i < 60 && find.byType(WorkspaceScreen).evaluate().isEmpty;
    i++
  ) {
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(find.byType(WorkspaceScreen), findsOneWidget);
  expect(
    tester.widget<AuthScreen>(find.byType(AuthScreen)).controller.member,
    isNotNull,
  );
  await tester.pumpAndSettle();
}

Future<void> openAccountSettings(WidgetTester tester) async {
  await waitForWorkspace(tester);
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Conta e sessão'));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('authenticated-member-name')), findsOneWidget);
}

Future<void> signOut(WidgetTester tester) async {
  await openAccountSettings(tester);
  await tester.ensureVisible(find.text('Terminar sessão'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Terminar sessão'));
  await tester.pumpAndSettle();
}
