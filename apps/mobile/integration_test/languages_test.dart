// Real API and PostgreSQL, isolated emulator and private synthetic accounts.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';
import 'package:homeoffice_mobile/l10n/generated/app_localizations.dart';
import 'package:homeoffice_mobile/theme/appearance.dart';

import 'planning_test.dart' as journey;
import 'session_helpers.dart' as session;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'PT EN DE real calendar/inbox and persistent settings in both themes',
    (t) async {
      app.main();
      await t.pumpAndSettle();
      await AppearanceScope.of(t.element(find.byType(MaterialApp)))!
          .selectLanguage('pt');
      await t.pumpAndSettle();
      await journey.login(t);
      await session.waitForWorkspace(t);
      for (final language in ['pt', 'en', 'de']) {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          await journey.tap(t, find.byIcon(Icons.settings_outlined).last);
          var context = t.element(find.byType(WorkspaceScreen));
          final c = AppearanceScope.of(context)!;
          await c.select(mode);
          await t.pumpAndSettle();
          await journey.tap(t, find.byKey(ValueKey('language-${c.language}')));
          await journey.tap(
            t,
            find
                .text(
                  {
                    'pt': 'Português',
                    'en': 'English',
                    'de': 'Deutsch',
                  }[language]!,
                )
                .last,
          );
          await t.pumpAndSettle();
          context = t.element(find.byType(WorkspaceScreen));
          final s = AppLocalizations.of(context)!;
          expect(s.localeName, language);
          await t.drag(find.byType(Scrollable).first, const Offset(0, 2000));
          await t.pumpAndSettle();
          await journey.screenshot(t, 'ho021-$language-${mode.name}-settings');
          await journey.tap(t, find.byIcon(Icons.calendar_month_outlined).last);
          await journey.ready(t);
          await journey.screenshot(t, 'ho021-$language-${mode.name}-calendar');
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
          expect(find.text(s.notificationFilter), findsWidgets);
          await journey.screenshot(
            t,
            'ho021-$language-${mode.name}-notifications',
          );
        }
      }
      // A new widget/controller reads the persisted language while restoring the real session.
      await t.pumpWidget(const SizedBox.shrink());
      app.main();
      await t.pumpAndSettle();
      await session.waitForWorkspace(t);
      expect(
        AppLocalizations.of(t.element(find.byType(WorkspaceScreen)))!
            .localeName,
        'de',
      );
      await AppearanceScope.of(t.element(find.byType(WorkspaceScreen)))!
          .selectLanguage('pt');
      await t.pumpAndSettle();
      await session.signOut(t);
    },
  );
}
