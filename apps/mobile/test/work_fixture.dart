import 'package:homeoffice_api/api.dart';
import 'package:http/http.dart' as http;

import 'planning_fixture.dart';
import 'auth_test.dart' show json;

class WorkFixture extends PlanningFixture {
  OnsiteView get onsite => OnsiteView(
    employeeId: actor,
    id: 'onsite',
    from: DateTime(2027, 3, 28),
    to: DateTime(2027, 3, 28),
    reason: 'Ensaio sintético',
    location: 'Zurique',
    reference: 'Máquina de teste',
    readAt: null,
    revision: version,
    state: OnsiteState.needsResolution,
    version: version,
  );
  TaskView get task => TaskView(
    employeeId: actor,
    id: 'task',
    title: 'Tarefa sintética',
    description: 'Descrição',
    deadline: DateTime(2027, 3, 28),
    state: AssignedTaskState.todo,
    requiresOnsite: true,
    requirementId: 'onsite',
    requirementRevision: version,
    requirementState: OnsiteState.needsResolution,
    progressNote: '',
    version: version,
  );
  Future<http.Response?> Function(http.Request)? workIntercept;
  WorkFixture() {
    intercept = (r) async {
      final custom = await workIntercept?.call(r);
      if (custom != null) return custom;
      final path = r.url.path;
      if (r.method != 'GET' &&
          (path.contains('/requirements') ||
              path.contains('/tasks') ||
              path.contains('/work/'))) {
        return json(
          MutationReceipt(
            contextId: path.contains('/tasks') || path.contains('/Task/')
                ? 'task'
                : 'onsite',
            version: version,
            calendarVersion: version,
            eventId: 'event',
          ),
        );
      }
      if (path.endsWith('/onsite-preview')) {
        return json(
          OnsitePreview(
            calendarVersion: version,
            result: OnsiteState.needsResolution,
            conflicts: [],
          ),
        );
      }
      if (path.endsWith('/requirements')) {
        return json(
          OnsitePage(
            calendarVersion: version,
            items: [onsite],
            nextOffset: null,
          ),
        );
      }
      if (path.endsWith('/requirements/onsite')) return json(onsite);
      if (path.endsWith('/tasks')) {
        return json(
          TaskPage(calendarVersion: version, items: [task], nextOffset: null),
        );
      }
      if (path.endsWith('/tasks/task')) return json(task);
      if (path.endsWith('/entries')) {
        return json(WorkEntryPage(items: [], nextOffset: null));
      }
      return null;
    };
  }
}
