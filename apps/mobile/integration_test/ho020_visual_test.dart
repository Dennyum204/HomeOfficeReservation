// Real isolated API, synthetic accounts. Screenshots exclude the login form.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';
import 'package:homeoffice_mobile/theme/appearance.dart';

import 'planning_test.dart' as journey;
import 'session_helpers.dart' as session;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('HO020 real calendar and unread inbox, light and dark', (
    t,
  ) async {
    for (final mode in [Brightness.light, Brightness.dark]) {
      binding.platformDispatcher.platformBrightnessTestValue = mode;
      app.main();
      await t.pumpAndSettle();
      await journey.login(t);
      await session.waitForWorkspace(t);
      await AppearanceScope.of(t.element(find.byType(WorkspaceScreen)))!
          .select(ThemeMode.system);
      await journey.tap(t, find.byIcon(Icons.calendar_month_outlined).last);
      await journey.ready(t);
      await journey.screenshot(t, 'ho020-after-${mode.name}-calendar');
      await journey.tap(t, find.byIcon(Icons.notifications_outlined).last);
      final inbox = t
          .widget<WorkspaceScreen>(find.byType(WorkspaceScreen))
          .inbox!;
      await journey.until(
        t,
        () => !inbox.loading && inbox.page != null,
        'real inbox',
      );
      expect(inbox.filter, 'unread');
      expect(find.text('Marcar como lida'), findsNothing);
      await journey.screenshot(t, 'ho020-after-${mode.name}-notifications');
      await session.signOut(t);
      await journey.until(
        t,
        () => find.byKey(const Key('email')).evaluate().isNotEmpty,
        'logout',
      );
      await t.pumpWidget(const SizedBox());
    }
  });
}
