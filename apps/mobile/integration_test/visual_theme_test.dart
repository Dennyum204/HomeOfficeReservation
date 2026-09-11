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

import 'planning_test.dart' as journey;

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
    expect(['before', 'after'], contains(stage));
    expect(requestId, isNotEmpty);
    for (final mode in [Brightness.light, Brightness.dark]) {
      binding.platformDispatcher.platformBrightnessTestValue = mode;
      app.main();
      await t.pumpAndSettle();
      await journey.login(t);
      await t.pumpAndSettle();
      if (stage == 'after') {
        final context = t.element(find.byType(WorkspaceScreen));
        await AppearanceScope.of(context)!.select(ThemeMode.system);
        await t.pumpAndSettle();
        expect(Theme.of(context).brightness, mode);
      }
      await journey.tap(t, find.byIcon(Icons.calendar_month_outlined).last);
      await journey.ready(t);
      await journey.tap(t, find.byKey(Key('calendar-$date')));
      await journey.screenshot(t, 'ho016-$stage-${mode.name}-calendar');
      await journey.open(t, requestId);
      await journey.screenshot(t, 'ho016-$stage-${mode.name}-request');
      await journey.tap(t, find.byIcon(Icons.arrow_back).last);
      if (stage == 'after') {
        await journey.tap(t, find.byIcon(Icons.calendar_month_outlined).last);
        await journey.ready(t);
        await journey.tap(t, find.byKey(const Key('planning-new-request')));
        await journey.screenshot(t, 'ho016-$stage-${mode.name}-editor');
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(journey.controller(t).editor, isNull);
        await journey.tap(t, find.byIcon(Icons.task_alt).last);
        final c = t
            .widget<WorkspaceScreen>(find.byType(WorkspaceScreen))
            .planning!;
        await c.openWork(WorkContext.requirement, requirementId);
        await t.pumpAndSettle();
        await journey.screenshot(t, 'ho016-$stage-${mode.name}-onsite');
        c.closeWork();
        await c.openWork(WorkContext.task, taskId);
        await t.pumpAndSettle();
        await journey.screenshot(t, 'ho016-$stage-${mode.name}-task');
        c.closeWork();
        await journey.tap(t, find.byIcon(Icons.notifications_outlined).last);
        await journey.screenshot(t, 'ho016-$stage-${mode.name}-notifications');
      }
      await journey.tap(t, find.byIcon(Icons.settings_outlined).last);
      await journey.screenshot(t, 'ho016-$stage-${mode.name}-settings');
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
    }
    binding.platformDispatcher.clearPlatformBrightnessTestValue();
  });
}
