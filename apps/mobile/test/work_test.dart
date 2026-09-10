import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/planning/planning_controller.dart';
import 'package:homeoffice_mobile/features/planning/planning_repository.dart';
import 'package:http/http.dart' as http;

import 'auth_test.dart' show json;
import 'work_fixture.dart';

void main() {
  test('work write journal replays the original generated payload and context after restart with one effect', () async {
    final f = WorkFixture();
    await f.start();
    addTearDown(f.dispose);
    await f.c.openWork(WorkContext.task, 'task');
    await f.c.editWork(progress: true);
    f.c.workEditor!.progress = f.c.workEditor!.progress!.copyWith(
      note: 'Progresso protegido',
      state: AssignedTaskState.inProgress,
    );
    f.c.workInputChanged();
    final keys = <String>{};
    var effects = 0;
    f.workIntercept = (r) async {
      if (r.method != 'GET' && keys.add(r.headers['Idempotency-Key']!)) {
        effects++;
        throw TimeoutException('simulated response lost after commit');
      }
      return null;
    };
    final command = f.c.prepare(
      PlanningOperation.progressTask,
      f.c.workEditor!.progress!.copyWith(
        expectedVersion: 1,
        expectedCalendarVersion: 1,
      ),
      request: 'task',
    );
    expect(await f.c.run(command), false);
    expect(f.c.workEditor!.progress!.note, 'Progresso protegido');
    expect(f.saved['journal']['body'], command.body);
    f.c.dispose();
    f.c = PlanningController(PlanningRepository(f.auth), f.store);
    await f.c.initialize();
    expect(f.writes, hasLength(1));
    expect(await f.c.recover(), true);
    expect(effects, 1);
    expect(f.writes.last.body, f.writes.first.body);
    expect(f.writes.last.headers['Idempotency-Key'], command.key);
    expect(f.c.task?.id, 'task');
    expect(f.c.journal, isNull);
  });
  test('onsite preview is invalidated on input, late preview after back cannot restore it, and stale edit requires review', () async {
    final f = WorkFixture();
    await f.start();
    addTearDown(f.dispose);
    await f.c.openWork(WorkContext.requirement, 'onsite');
    await f.c.editWork();
    await f.c.previewWork();
    expect(f.c.editorPreview, isNotNull);
    f.c.workEditor!.onsite = f.c.workEditor!.onsite!.copyWith(
      reason: 'Motivo preservado',
    );
    f.c.workInputChanged();
    expect(f.c.editorPreview, isNull);
    final command = f.c.prepare(
      PlanningOperation.editRequirement,
      f.c.workEditor!.onsite!.copyWith(
        expectedVersion: 1,
        expectedCalendarVersion: 1,
      ),
      request: 'onsite',
    );
    f.workIntercept = (r) async {
      if (r.method != 'GET') {
        f.version = 2;
        return json({'code': 'calendar_version_stale'}, 412);
      }
      return null;
    };
    expect(await f.c.run(command), false);
    expect(f.c.needsReview, true);
    expect(f.c.workEditor!.onsite!.reason, 'Motivo preservado');
    expect(f.c.requirement!.revision, 2);
    expect(f.c.editorPreview, isNull);
    expect(await f.c.run(command), false);
    f.c.reviewed();
    expect(f.c.workCanWrite, true);
    final started = Completer<void>(), response = Completer<http.Response>();
    f.workIntercept = (r) async {
      if (r.url.path.endsWith('/onsite-preview')) {
        started.complete();
        return response.future;
      }
      return null;
    };
    final pending = f.c.previewWork();
    await started.future;
    f.c.closeWorkEditor();
    response.complete(
      json(OnsitePreview(calendarVersion: 2, result: OnsiteState.active)),
    );
    await pending;
    expect(f.c.workEditor, isNull);
    expect(f.c.editorPreview, isNull);
    expect(f.c.workLoading, false);
  });
  test('late work read and comment draft cannot cross logout, and current forbidden detail clears data', () async {
    final f = WorkFixture();
    await f.start();
    addTearDown(f.dispose);
    await f.c.openWork(WorkContext.task, 'task');
    f.c.workCommentDrafts[f.c.workCommentKey] = 'Privado';
    await f.c.persist();
    f.workIntercept = (r) async => r.url.path.endsWith('/tasks/task')
        ? json({'code': 'forbidden'}, 403)
        : null;
    expect(await f.c.openWork(WorkContext.task, 'task'), false);
    expect(f.c.task, isNull);
    expect(f.c.workCanWrite, false);
    f.c.dispose();
    await f.start();
    f.c.workCommentDrafts['member:requirement:onsite'] = 'Privado';
    await f.c.persist();
    final started = Completer<void>(), response = Completer<http.Response>();
    f.workIntercept = (r) async {
      if (r.url.path.endsWith('/requirements/onsite')) {
        started.complete();
        return response.future;
      }
      return null;
    };
    final pending = f.c.openWork(WorkContext.requirement, 'onsite');
    await started.future;
    await f.auth.logout();
    response.complete(json(f.onsite));
    expect(await pending, false);
    expect(f.c.requirement, isNull);
    expect(f.c.workCommentDrafts, isEmpty);
    expect(f.store.value, isNull);
  });
  test('missing destinations and an unassigned employee never retain the previous work detail', () async {
    final f = WorkFixture();
    await f.start();
    addTearDown(f.dispose);
    await f.c.openWork(WorkContext.task, 'task');
    expect(f.c.task, isNotNull);
    f.workIntercept = (r) async => r.url.path.endsWith('/tasks/missing')
        ? json({'code': 'not_found'}, 404)
        : null;
    expect(await f.c.openWork(WorkContext.task, 'missing'), false);
    expect(f.c.task, isNull);
    expect(f.c.failure, PlanningFailure.missing);
    expect(f.c.workCanWrite, false);
    await f.c.openWork(WorkContext.requirement, 'onsite');
    expect(f.c.requirement, isNotNull);
    expect(
      await f.c.openWork(WorkContext.task, 'task', target: 'unassigned'),
      false,
    );
    expect(f.c.requirement, isNull);
    expect(f.c.task, isNull);
    expect(f.c.failure, PlanningFailure.forbidden);
    expect(f.c.workCanWrite, false);
    expect(f.writes, isEmpty);
  });
  test('linked task creation closes to a task list and restores private form without altering the requirement', () async {
    final f = WorkFixture();
    await f.start();
    addTearDown(f.dispose);
    await f.c.openWork(WorkContext.requirement, 'onsite');
    await f.c.editWork(creating: true, linked: f.c.requirement);
    expect(f.c.workId, isNull);
    expect(f.c.workKind, WorkContext.task);
    expect(f.c.linkedRequirement?.id, 'onsite');
    f.c.workEditor!.task = f.c.workEditor!.task!.copyWith(
      title: 'Rascunho protegido',
    );
    f.c.workInputChanged();
    await f.c.persist();
    f.c.closeWorkEditor();
    await f.c.editWork(creating: true);
    expect(f.c.workEditor!.task!.title, 'Rascunho protegido');
    expect(f.c.workEditor!.task!.requirementId, 'onsite');
    expect(f.writes, isEmpty);
    expect(jsonDecode(f.store.value!)['workEditors'], isNotEmpty);
  });
}
