// Manual, read-only visual acceptance against an isolated API with synthetic data.
// The driver exports only captures taken after login, never the credential form.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/planning/planning_controller.dart';
import 'package:homeoffice_mobile/theme/appearance.dart';
import 'package:homeoffice_mobile/theme/components.dart';
import 'package:homeoffice_mobile/features/auth/auth_screen.dart';
import 'package:homeoffice_mobile/features/auth/token_store.dart';
import 'package:homeoffice_mobile/config/api_settings.dart';

import 'planning_test.dart' as journey;
import 'session_helpers.dart';

const stage = String.fromEnvironment('VISUAL_STAGE', defaultValue: 'after');
const requestId = String.fromEnvironment('VISUAL_REQUEST_ID');
const date = String.fromEnvironment('VISUAL_DATE');
const requirementId = String.fromEnvironment('VISUAL_REQUIREMENT_ID');
const taskId = String.fromEnvironment('VISUAL_TASK_ID');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('real synthetic calendar, requests and settings in both themes', (
    t,
  ) async {
    expect(['before', 'after', 'header'], contains(stage));
    expect(requestId, isNotEmpty);
    Future<void> capture(
      String name,
      Brightness mode, {
      bool scroll = false,
    }) async {
      if (stage == 'header') {
        t
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await t.pumpAndSettle();
        expect(find.byType(SectionHeading).hitTestable(), findsOneWidget);
        expect(find.byType(AppBar), findsNothing);
        expect(find.byType(SliverAppBar), findsNothing);
        if (!name.endsWith('settings')) {
          expect(
            find.byKey(const Key('authenticated-member-name')),
            findsNothing,
          );
          expect(find.text('Verificar sessão'), findsNothing);
        }
      }
      await journey.screenshot(t, 'ho016-$stage-${mode.name}-$name');
      if (stage == 'header' && scroll) {
        final scrollState = t.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        final heading = find.byType(SectionHeading);
        final top = t.getTopLeft(heading).dy;
        final extent = scrollState.position.maxScrollExtent;
        if (extent < t.getSize(heading).height + 16) {
          // A short real inbox can fit. Do not label an unmoved capture as scrolled.
          expect(
            name,
            'notifications',
            reason: 'Other seeded screens must have scrollable content.',
          );
          await t.drag(find.byType(Scrollable).first, const Offset(0, -800));
          await t.pumpAndSettle();
          expect(t.getTopLeft(heading).dy, closeTo(top - extent, 1));
          debugPrint(
            'Visual $name/${mode.name}: short content, scroll extent $extent; overflow scrolling is covered by widget fixtures.',
          );
          return;
        }
        await t.drag(find.byType(Scrollable).first, const Offset(0, -800));
        await t.pumpAndSettle();
        expect(find.byType(SectionHeading).hitTestable(), findsNothing);
        expect(find.byType(NavigationBar).hitTestable(), findsOneWidget);
        await journey.screenshot(t, 'ho016-$stage-${mode.name}-$name-scrolled');
      }
    }

    for (final mode in [Brightness.light, Brightness.dark]) {
      binding.platformDispatcher.platformBrightnessTestValue = mode;
      app.main();
      await t.pumpAndSettle();
      await journey.login(t);
      await t.pumpAndSettle();
      if (stage != 'before') {
        final context = t.element(find.byType(WorkspaceScreen));
        await AppearanceScope.of(context)!.select(ThemeMode.system);
        await t.pumpAndSettle();
        expect(Theme.of(context).brightness, mode);
      }
      await journey.tap(t, find.byIcon(Icons.calendar_month_outlined).last);
      await journey.ready(t);
      await journey.tap(t, find.byKey(Key('calendar-$date')));
      await capture('calendar', mode, scroll: true);
      await journey.open(t, requestId);
      await capture('request', mode, scroll: true);
      await journey.tap(t, find.byIcon(Icons.arrow_back).last);
      if (stage != 'before') {
        await journey.tap(t, find.byIcon(Icons.calendar_month_outlined).last);
        await journey.ready(t);
        await journey.tap(t, find.byKey(const Key('planning-new-request')));
        await capture('editor', mode);
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(journey.controller(t).editor, isNull);
        await journey.tap(t, find.byIcon(Icons.task_alt).last);
        final c = t
            .widget<WorkspaceScreen>(find.byType(WorkspaceScreen))
            .planning!;
        await c.openWork(WorkContext.requirement, requirementId);
        await t.pumpAndSettle();
        await capture('onsite', mode, scroll: true);
        c.closeWork();
        await c.openWork(WorkContext.task, taskId);
        await t.pumpAndSettle();
        await capture('task', mode);
        c.closeWork();
        await journey.tap(t, find.byIcon(Icons.notifications_outlined).last);
        final inbox = t
            .widget<WorkspaceScreen>(find.byType(WorkspaceScreen))
            .inbox!;
        await journey.until(
          t,
          () => !inbox.loading && inbox.page != null,
          'real inbox finishes loading',
        );
        await capture('notifications', mode, scroll: true);
      }
      await journey.tap(t, find.byIcon(Icons.settings_outlined).last);
      await capture('settings', mode, scroll: true);
      if (stage == 'header') {
        final auth = t.widget<AuthScreen>(find.byType(AuthScreen)).controller;
        final identity = auth.member!.memberId;
        await journey.tap(t, find.text('Verificar sessão'));
        await journey.until(
          t,
          () => !auth.busy,
          'manual session check completes in Settings',
        );
        expect(auth.member!.memberId, identity);
        expect(auth.message.name, 'none');
        await signOut(t);
        await journey.until(
          t,
          () => auth.member == null,
          'Settings logout clears identity',
        );
        expect(await SecureTokenStore(ApiSettings.baseUrl).read(), isNull);
        expect(auth.notificationIntent, isNull);
        expect(find.byType(WorkspaceScreen), findsNothing);
        await journey.login(t, manager: true);
        final planning = journey.controller(t);
        expect(planning.actor, isNot(identity));
        expect(planning.employees.any((m) => m.memberId == identity), isTrue);
        await journey.tap(
          t,
          find.byKey(ValueKey('employee-${planning.employeeId}')),
        );
        final employee = planning.employees.singleWhere(
          (m) => m.memberId == identity,
        );
        await journey.tap(t, find.text(employee.displayName).last);
        await journey.ready(t);
        expect(planning.employeeId, identity);
        await capture('manager-calendar', mode);
        await openAccountSettings(t);
        expect(
          t
              .widget<Text>(find.byKey(const Key('authenticated-member-name')))
              .data,
          auth.member!.displayName,
        );
        expect(auth.member!.memberId, isNot(identity));
        await capture('manager-settings', mode);
        await signOut(t);
        await journey.until(t, () => auth.member == null, 'manager logout');
      }
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
    }
    binding.platformDispatcher.clearPlatformBrightnessTestValue();
  });
}
