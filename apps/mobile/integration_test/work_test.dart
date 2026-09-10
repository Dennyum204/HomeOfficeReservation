// Real Android UI / generated client / API / PostgreSQL. Only new synthetic fixtures.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/features/planning/planning_controller.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';

import 'planning_test.dart' as p;

PlanningController c(WidgetTester t) =>
    t.widget<WorkspaceScreen>(find.byType(WorkspaceScreen)).planning!;
Future<void> ready(WidgetTester t) => p.until(
  t,
  () =>
      c(t).initialized &&
      !c(t).loading &&
      !c(t).opening &&
      !c(t).workLoading &&
      !c(t).busy,
  'current authorized work data',
);
Future<T> api<T>(
  Future<T> Function(PlanningApi) action, {
  bool manager = false,
}) async {
  final client = await p.client(manager: manager);
  try {
    return await action(PlanningApi(client));
  } finally {
    client.client.close();
  }
}

String key() => 'ho011-${DateTime.now().microsecondsSinceEpoch}';
Future<CalendarView> calendar(String employee, DateTime day) =>
    api((a) async => (await a.getCalendar(employee, day, day))!);
Future<void> field(WidgetTester t, String key, String value) async {
  final finder = find.byKey(Key(key));
  await t.ensureVisible(finder);
  await t.pumpAndSettle();
  await t.enterText(finder, value);
  FocusManager.instance.primaryFocus?.unfocus();
  await t.pumpAndSettle();
}

Future<void> selectEmployee(WidgetTester t, String employee) async {
  if (c(t).employeeId == employee) return;
  final member = c(t).employees.singleWhere((m) => m.memberId == employee);
  await p.tap(t, find.byKey(ValueKey('employee-${c(t).employeeId}')));
  await p.tap(t, find.text(member.displayName).last);
  await ready(t);
}

Future<void> openWork(
  WidgetTester t,
  String employee,
  WorkContext kind,
  String id,
) async {
  await p.tap(t, find.byIcon(Icons.task_alt));
  await ready(t);
  await selectEmployee(t, employee);
  if (c(t).workEditor != null) {
    await p.tap(t, find.text('Voltar', skipOffstage: false).last);
  }
  await p.tap(
    t,
    find.widgetWithText(
      ChoiceChip,
      kind == WorkContext.requirement ? 'Presenças' : 'Tarefas',
    ),
  );
  await ready(t);
  for (var page = 0; page < 100; page++) {
    final model = c(t);
    final found = kind == WorkContext.requirement
        ? model.requirements?.items.any((r) => r.id == id) == true
        : model.tasks?.items.any((r) => r.id == id) == true;
    if (found) break;
    final next = kind == WorkContext.requirement
        ? model.requirements?.nextOffset
        : model.tasks?.nextOffset;
    expect(
      next,
      isNotNull,
      reason: 'Synthetic resource must exist on a real page.',
    );
    await p.tap(t, find.text('Seguintes').last);
    await ready(t);
  }
  await p.tap(t, find.byKey(Key('work-open-$id')));
  await ready(t);
  expect(c(t).workId, id);
}

Future<void> confirm(WidgetTester t, String button) async {
  await p.tap(t, find.byKey(Key(button)));
  expect(c(t).review, isNotNull);
  await p.tap(t, find.byKey(const Key('planning-confirm')));
  await ready(t);
  expect(c(t).journal, isNull);
  expect(c(t).failure, PlanningFailure.none);
}

Future<void> date(WidgetTester t, String key, DateTime value) async {
  await p.tap(t, find.byKey(Key(key)));
  await p.tap(t, find.byIcon(Icons.edit_outlined));
  final dialog = find.byType(DatePickerDialog);
  await t.enterText(
    find.descendant(of: dialog, matching: find.byType(TextField)),
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
  );
  await p.tap(
    t,
    find.descendant(
      of: dialog,
      matching: find.text(
        MaterialLocalizations.of(t.element(dialog)).okButtonLabel,
      ),
    ),
  );
}

Future<String> approvedFixture(String employee, DateTime day) async {
  final draft = await api((a) async {
    final v = (await a.getCalendar(employee, day, day))!.calendarVersion;
    final receipt = (await a.createPlanningDraft(
      employee,
      key(),
      DraftInput(
        expectedCalendarVersion: v,
        expectedRequestVersion: null,
        parentRevisionId: null,
        note: 'Ensaio HO-011 — aprovação preservada',
        days: [
          DayInput(
            localDate: day,
            location: WorkLocation.remotePortugal,
            availability: Availability.working,
          ),
        ],
      ),
    ))!;
    await a.submitPlanningRequest(
      employee,
      receipt.contextId,
      key(),
      SubmitInput(
        expectedCalendarVersion: receipt.calendarVersion,
        expectedRequestVersion: receipt.version,
      ),
    );
    return receipt.contextId;
  });
  await api((a) async {
    final r = (await a.getPlanningRequest(employee, draft))!,
        v = (await a.getCalendar(employee, day, day))!;
    await a.decidePlanningDays(
      employee,
      draft,
      key(),
      DecisionInput(
        approve: true,
        expectedCalendarVersion: v.calendarVersion,
        expectedRequestVersion: r.version,
        reason: null,
        days: r.days
            .map((d) => SelectedDay(dayId: d.id, expectedVersion: d.version))
            .toList(),
      ),
    );
  }, manager: true);
  return draft;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android onsite revisions, acknowledgement, explicit resolution and linked task progress preserve authoritative plans',
    (t) async {
      expect(Platform.isAndroid, true);
      expect(
        [
          p.email,
          p.password,
          p.managerEmail,
          p.managerPassword,
        ].every((v) => v.isNotEmpty),
        true,
      );
      app.main();
      await t.pumpAndSettle();
      await p.login(t);
      final employee = c(t).actor;
      p.selectedEmployee = employee;
      final day = (await p.freeWeek(employee)).first;
      final request = await approvedFixture(employee, day);
      final marker =
          'Ensaio Android HO-011 ${DateTime.now().microsecondsSinceEpoch}';
      await p.login(t, manager: true);
      await p.tap(t, find.byIcon(Icons.task_alt));
      await ready(t);
      await selectEmployee(t, employee);
      await p.tap(t, find.byKey(const Key('work-new')));
      await field(t, 'work-reason', marker);
      await field(t, 'work-location', 'Oficina de Zurique');
      await field(t, 'work-reference', 'Máquina sintética');
      await date(t, 'work-from', day);
      await date(t, 'work-to', day);
      await p.tap(t, find.byKey(const Key('work-preview')));
      await ready(t);
      expect(c(t).editorPreview!.result, OnsiteState.needsResolution);
      await confirm(t, 'work-save');
      final requirement = c(t).requirement!.id;
      expect(c(t).requirement!.state, OnsiteState.needsResolution);
      expect(
        (await calendar(employee, day)).effectiveDays.single.location,
        WorkLocation.remotePortugal,
      );
      await p.screenshot(t, 'ho011-android-onsite-conflict');
      await p.login(t);
      await openWork(t, employee, WorkContext.requirement, requirement);
      await confirm(t, 'work-acknowledge');
      expect(c(t).requirement!.readAt, isNotNull);
      expect(
        (await calendar(employee, day)).effectiveDays.single.location,
        WorkLocation.remotePortugal,
      );
      await p.login(t, manager: true);
      await openWork(t, employee, WorkContext.requirement, requirement);
      await p.tap(t, find.byKey(const Key('work-edit')));
      await field(t, 'work-reference', 'Máquina sintética — revisão 2');
      await p.tap(t, find.byKey(const Key('work-preview')));
      await ready(t);
      await confirm(t, 'work-save');
      expect(c(t).requirement!.revision, 2);
      expect(c(t).requirement!.readAt, isNull);
      await p.login(t);
      await openWork(t, employee, WorkContext.requirement, requirement);
      await confirm(t, 'work-acknowledge');
      expect(c(t).requirement!.readAt, isNotNull);
      await p.login(t, manager: true);
      await openWork(t, employee, WorkContext.requirement, requirement);
      await p.tap(t, find.byKey(Key('work-resolve-$request')));
      await p.ready(t);
      expect(c(t).editor!.requirementId, requirement);
      expect(c(t).editor!.days.single.location, WorkLocation.officeSwitzerland);
      await p.confirm(t, 'editor-save');
      final proposal = c(t).proposals!.items.first;
      expect(
        (await calendar(employee, day)).effectiveDays.single.location,
        WorkLocation.remotePortugal,
      );
      await p.login(t);
      await p.open(t, request);
      await p.tap(t, find.byKey(Key('accept-${proposal.id}')));
      await p.tap(t, find.byKey(const Key('planning-confirm')));
      await p.ready(t);
      final replacement = c(t).detail!.id;
      expect(
        (await calendar(employee, day)).effectiveDays.single.location,
        WorkLocation.remotePortugal,
      );
      await p.login(t, manager: true);
      await p.open(t, replacement);
      await p.confirm(t, 'request-approve');
      final resolved = await calendar(employee, day);
      expect(
        resolved.effectiveDays.single.location,
        WorkLocation.officeSwitzerland,
      );
      expect(
        resolved.requirements.singleWhere((r) => r.id == requirement).state,
        OnsiteState.active,
      );
      await openWork(t, employee, WorkContext.requirement, requirement);
      await p.tap(t, find.byKey(const Key('work-assign-linked')));
      await field(t, 'work-title', '$marker — tarefa');
      await field(t, 'work-description', 'Verificar a máquina de teste');
      await confirm(t, 'work-save');
      final task = c(t).task!.id;
      expect(c(t).task!.requirementId, requirement);
      expect(c(t).task!.requiresOnsite, true);
      final beforeTask = (await calendar(employee, day)).effectiveDays;
      await p.login(t);
      await openWork(t, employee, WorkContext.task, task);
      expect(find.byKey(const Key('work-edit')), findsNothing);
      await p.tap(t, find.byKey(const Key('work-progress')));
      await p.tap(t, find.byKey(const Key('work-progress-state')));
      await p.tap(t, find.text('Em curso').last);
      await field(t, 'work-progress-note', 'Verificação iniciada');
      await confirm(t, 'work-save');
      expect(c(t).task!.state, AssignedTaskState.inProgress);
      expect((await calendar(employee, day)).effectiveDays, beforeTask);
      final comment = find.byType(TextFormField).last;
      await t.ensureVisible(comment);
      await t.enterText(comment, 'Comentário sintético HO-011');
      await t.pumpAndSettle();
      await confirm(t, 'work-comment-send');
      expect(
        c(t).workEntries!.items.any((e) => e.action == 'work.commented'),
        true,
      );
      await t.ensureVisible(find.byKey(const Key('work-detail-title')));
      await t.pumpAndSettle();
      await p.screenshot(t, 'ho011-android-linked-task');
      await p.login(t, manager: true);
      await openWork(t, employee, WorkContext.requirement, requirement);
      await confirm(t, 'work-cancel');
      expect(c(t).requirement!.state, OnsiteState.cancelled);
      await openWork(t, employee, WorkContext.task, task);
      expect(c(t).linkedRequirement!.state, OnsiteState.cancelled);
      expect(c(t).task!.state, AssignedTaskState.inProgress);
      expect((await calendar(employee, day)).effectiveDays, beforeTask);
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}
