// Run one Android handoff phase between the real Web phases in core-acceptance.mjs.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/features/planning/planning_dates.dart';

import 'planning_test.dart' as p;
import 'work_test.dart' as w;

const phase = String.fromEnvironment('TEST_CORE_PHASE'),
    employee = String.fromEnvironment('TEST_CORE_EMPLOYEE'),
    request = String.fromEnvironment('TEST_CORE_REQUEST'),
    requirement = String.fromEnvironment('TEST_CORE_ONSITE'),
    proposal = String.fromEnvironment('TEST_CORE_PROPOSAL'),
    task = String.fromEnvironment('TEST_CORE_TASK');
final from = DateTime.parse(const String.fromEnvironment('TEST_CORE_FROM')),
    to = DateTime.parse(const String.fromEnvironment('TEST_CORE_TO'));
Future<void> verify({bool resolved = false, int pending = 0}) async {
  for (final manager in [false, true]) {
    final v = await w.api(
      (a) async => (await a.getCalendar(employee, from, to))!,
      manager: manager,
    );
    expect(
      v.effectiveDays.where((d) => d.origin == 'ApprovedRequest'),
      hasLength(3),
    );
    expect(v.pendingDays, hasLength(pending));
    expect(
      v.effectiveDays.singleWhere((d) => sameDay(d.localDate, from)).location,
      resolved ? WorkLocation.officeSwitzerland : WorkLocation.remotePortugal,
    );
    expect(
      v.effectiveDays.where(
        (d) =>
            d.origin == 'ApprovedRequest' &&
            d.location == WorkLocation.remotePortugal,
      ),
      hasLength(resolved ? 2 : 3),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('real Web/Android handoff: $phase', (t) async {
    expect(
      ['planning', 'acknowledge', 'resolve', 'progress'].contains(phase),
      true,
    );
    expect(employee.isNotEmpty && request.isNotEmpty, true);
    p.selectedEmployee = employee;
    app.main();
    await t.pumpAndSettle();
    if (phase == 'planning') {
      await p.login(t, manager: true);
      await p.open(t, request);
      expect(w.c(t).detail!.days, hasLength(5));
      for (final d in w.c(t).detail!.days.skip(3)) {
        await p.tap(t, find.byKey(Key('select-${dateKey(d.localDate)}')));
      }
      expect(w.c(t).chosen, hasLength(3));
      await p.confirm(t, 'request-approve');
      await verify(pending: 2);
      await p.login(t);
      await p.open(t, request);
      expect(w.c(t).chosen, hasLength(2));
      await p.confirm(t, 'request-withdraw');
      await verify();
      await t.ensureVisible(find.byKey(const Key('request-counts')));
      await t.pumpAndSettle();
      await p.screenshot(t, 'ho011-android-web-request-withdrawn');
    } else if (phase == 'acknowledge') {
      await p.login(t);
      await w.openWork(t, employee, WorkContext.requirement, requirement);
      expect(w.c(t).requirement!.state, OnsiteState.needsResolution);
      await w.confirm(t, 'work-acknowledge');
      expect(w.c(t).requirement!.readAt, isNotNull);
      await verify();
      await t.ensureVisible(find.byKey(const Key('work-detail-title')));
      await t.pumpAndSettle();
      await p.screenshot(t, 'ho011-android-web-presence-read');
    } else if (phase == 'resolve') {
      await p.login(t);
      await p.open(t, request);
      await p.tap(t, find.byKey(Key('accept-$proposal')));
      await p.tap(t, find.byKey(const Key('planning-confirm')));
      await p.ready(t);
      final revision = w.c(t).detail!.id;
      expect(revision, isNot(request));
      await verify(pending: 1);
      await p.login(t, manager: true);
      await p.open(t, revision);
      await p.confirm(t, 'request-approve');
      await verify(resolved: true);
      await w.openWork(t, employee, WorkContext.requirement, requirement);
      expect(w.c(t).requirement!.state, OnsiteState.active);
    } else {
      await p.login(t);
      await w.openWork(t, employee, WorkContext.task, task);
      expect(w.c(t).task!.requirementId, requirement);
      await p.tap(t, find.byKey(const Key('work-progress')));
      await p.tap(t, find.byKey(const Key('work-progress-state')));
      await p.tap(t, find.text('Em curso').last);
      await w.field(t, 'work-progress-note', 'Progresso confirmado no Android');
      await w.confirm(t, 'work-save');
      expect(w.c(t).task!.state, AssignedTaskState.inProgress);
      await verify(resolved: true);
      await t.ensureVisible(find.byKey(const Key('work-detail-title')));
      await t.pumpAndSettle();
      await p.screenshot(t, 'ho011-android-web-task-progress');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
