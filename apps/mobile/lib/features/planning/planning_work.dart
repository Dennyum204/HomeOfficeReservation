part of 'planning_controller.dart';

// Onsite/tasks share the employee scope, protected journal and session lifecycle
// with planning. Reads have a separate generation; all writes remain serialized.
extension PlanningWork on PlanningController {
  String get workDraftKey => '$employeeId:${workEditor!.draftKey}';
  String get workCommentKey => '$employeeId:${workKind.name}:$workId';
  bool get workCanWrite => canWrite && !workStale;

  void _resetWork() {
    _workQuery++;
    _workPreviewQuery++;
    workId = null;
    requirement = null;
    task = null;
    linkedRequirement = null;
    requirements = null;
    tasks = null;
    workEntries = null;
    workConflicts = null;
    editorPreview = null;
    editorPreviewFingerprint = null;
    workEditor = null;
    requirementOptions = null;
    workOffset = 0;
    entryOffset = 0;
    workLoading = false;
    workStale = false;
    requirementFilter = null;
    taskFilter = null;
  }

  Future<void> selectWorkKind(WorkContext kind) async {
    if (!active || locked) return;
    try {
      await persist();
    } catch (_) {
      failure = PlanningFailure.storage;
      _notify();
      return;
    }
    if (!active) return;
    _resetWork();
    workKind = kind;
    await loadWork();
  }

  Future<void> loadWork({int? page}) async {
    if (!active || employeeId == null) return;
    if (page != null) workOffset = page;
    final scope = _scope,
        query = ++_workQuery,
        employee = employeeId!,
        kind = workKind;
    workLoading = true;
    _notify();
    try {
      final result = kind == WorkContext.requirement
          ? await repository.read(
              () => repository.api.listOnsiteRequirements(
                employee,
                offset: workOffset,
                limit: 25,
                state: requirementFilter,
              ),
            )
          : await repository.read(
              () => repository.api.listAssignedTasks(
                employee,
                offset: workOffset,
                limit: 25,
                state: taskFilter,
              ),
            );
      if (!_current(scope) || query != _workQuery) return;
      if (kind == WorkContext.requirement) {
        requirements = result as OnsitePage?;
      } else {
        tasks = result as TaskPage?;
      }
      await refresh();
      if (!_current(scope) || query != _workQuery) return;
      final version = kind == WorkContext.requirement
          ? requirements?.calendarVersion
          : tasks?.calendarVersion;
      workStale = dataStale || version != calendar?.calendarVersion;
      if (workStale) {
        failure = PlanningFailure.stale;
      } else if (!needsReview && journal == null) {
        failure = PlanningFailure.none;
      }
    } catch (error) {
      if (_current(scope) && query == _workQuery) _workError(error);
    } finally {
      if (_current(scope) && query == _workQuery) {
        workLoading = false;
        _notify();
      }
    }
  }

  void _workError(Object error) {
    failure = _failure(error);
    workStale = true;
    if ({
      PlanningFailure.forbidden,
      PlanningFailure.missing,
    }.contains(failure)) {
      requirements = null;
      tasks = null;
      requirement = null;
      task = null;
      linkedRequirement = null;
      workEntries = null;
      workConflicts = null;
      workEditor = null;
      editorPreview = null;
    }
  }

  Future<bool> openWork(
    WorkContext kind,
    String id, {
    String? target,
    bool preserveEditor = false,
  }) async {
    if (target != null && target != employeeId) {
      if (locked || !employees.any((e) => e.memberId == target)) {
        _resetWork();
        workKind = kind;
        workId = id;
        workStale = true;
        failure = PlanningFailure.forbidden;
        _notify();
        return false;
      }
      await selectEmployee(target);
    }
    if (!active || employeeId == null) return false;
    _workPreviewQuery++;
    final scope = _scope, query = ++_workQuery, employee = employeeId!;
    if (id != workId || kind != workKind) {
      requirement = null;
      task = null;
      linkedRequirement = null;
      workEntries = null;
      workConflicts = null;
      entryOffset = 0;
    }
    workKind = kind;
    workId = id;
    if (!preserveEditor) workEditor = null;
    if (!needsReview && journal == null) failure = PlanningFailure.none;
    workLoading = true;
    _notify();
    try {
      final values = await Future.wait([
        repository.read(
          () => kind == WorkContext.requirement
              ? repository.api.getOnsiteRequirement(employee, id)
              : repository.api.getAssignedTask(employee, id),
        ),
        repository.read(
          () => repository.api.listWorkEntries(
            employee,
            kind,
            id,
            offset: entryOffset,
            limit: 25,
          ),
        ),
      ]);
      if (!_current(scope) || query != _workQuery) return false;
      requirement = values[0] is OnsiteView ? values[0] as OnsiteView : null;
      task = values[0] is TaskView ? values[0] as TaskView : null;
      workEntries = values[1] as WorkEntryPage?;
      final r = requirement, link = task?.requirementId;
      final preview = r != null && r.state != OnsiteState.cancelled
          ? await repository.read(
              () => repository.api.previewOnsiteRequirement(
                employee,
                r.from,
                r.to,
                r.location,
                excludes: r.id,
              ),
            )
          : null;
      final linked = link != null
          ? await repository.read(
              () => repository.api.getOnsiteRequirement(employee, link),
            )
          : null;
      if (!_current(scope) || query != _workQuery) return false;
      workConflicts = preview;
      linkedRequirement = linked;
      await refresh();
      if (!_current(scope) || query != _workQuery) return false;
      workStale =
          dataStale ||
          (preview != null &&
              preview.calendarVersion != calendar?.calendarVersion);
      if (workStale) failure = PlanningFailure.stale;
      return !workStale;
    } catch (error) {
      if (_current(scope) && query == _workQuery) _workError(error);
      return false;
    } finally {
      if (_current(scope) && query == _workQuery) {
        workLoading = false;
        _notify();
      }
    }
  }

  void closeWork() {
    if (locked) return;
    _workQuery++;
    _workPreviewQuery++;
    workId = null;
    requirement = null;
    task = null;
    linkedRequirement = null;
    workEditor = null;
    workEntries = null;
    workConflicts = null;
    editorPreview = null;
    workLoading = false;
    _notify();
  }

  Future<void> editWork({
    bool creating = false,
    bool progress = false,
    OnsiteView? linked,
  }) async {
    if (!workCanWrite || employeeId == null) return;
    final today = planningToday(calendar?.planningTimeZone ?? 'Europe/Zurich');
    final id = creating ? null : workId;
    final mode = linked == null ? workKind : WorkContext.task;
    final key = '$employeeId:${mode.name}:${id ?? "new"}:$progress';
    final r = requirement, t = task;
    if (creating && linked != null) {
      workId = null;
      requirement = null;
      task = null;
      workEntries = null;
      workConflicts = null;
      linkedRequirement = linked;
    }
    workEditor =
        workEditors[key] ??
        (mode == WorkContext.requirement
            ? WorkEditor(
                id: id,
                onsite: OnsiteInput(
                  expectedCalendarVersion: null,
                  expectedVersion: null,
                  from: creating ? selectedDate : r!.from,
                  to: creating ? selectedDate : r!.to,
                  reason: creating ? '' : r!.reason,
                  location: creating ? '' : r!.location,
                  reference: creating ? '' : r!.reference,
                ),
              )
            : progress
            ? WorkEditor(
                id: id,
                progress: TaskProgressInput(
                  expectedCalendarVersion: null,
                  expectedVersion: null,
                  note: t!.progressNote,
                  state: t.state,
                ),
              )
            : WorkEditor(
                id: id,
                task: TaskInput(
                  expectedCalendarVersion: null,
                  expectedVersion: null,
                  title: creating ? '' : t!.title,
                  description: creating ? '' : t!.description,
                  deadline: creating ? (linked?.to ?? today) : t!.deadline,
                  state: creating ? AssignedTaskState.todo : t!.state,
                  requiresOnsite: creating ? linked != null : t!.requiresOnsite,
                  requirementId: creating ? linked?.id : t!.requirementId,
                ),
              ));
    workKind = mode;
    editorPreview = null;
    editorPreviewFingerprint = null;
    workInputChanged();
    if (mode == WorkContext.task && !progress) await loadRequirementOptions();
  }

  void workInputChanged() {
    if (!active || workEditor == null) return;
    workEditors[workDraftKey] = workEditor!;
    editorPreview = null;
    editorPreviewFingerprint = null;
    inputChanged();
  }

  void closeWorkEditor({bool discard = false}) {
    if (locked || workEditor == null) return;
    _workPreviewQuery++;
    workLoading = false;
    if (discard) workEditors.remove(workDraftKey);
    workEditor = null;
    editorPreview = null;
    inputChanged();
  }

  String get workPreviewFingerprint => jsonEncode(workEditor?.onsite);
  Future<void> previewWork() async {
    final r = workEditor?.onsite;
    if (!active || r == null || employeeId == null || locked) return;
    final scope = _scope,
        query = ++_workPreviewQuery,
        fingerprint = workPreviewFingerprint;
    workLoading = true;
    _notify();
    try {
      final result = await repository.read(
        () => repository.api.previewOnsiteRequirement(
          employeeId!,
          r.from,
          r.to,
          r.location,
          excludes: workEditor!.id,
        ),
      );
      await refresh();
      if (!_current(scope) ||
          query != _workPreviewQuery ||
          fingerprint != workPreviewFingerprint) {
        return;
      }
      editorPreview = result;
      editorPreviewFingerprint = fingerprint;
      workStale =
          dataStale || result?.calendarVersion != calendar?.calendarVersion;
      if (workStale) failure = PlanningFailure.stale;
    } catch (error) {
      if (_current(scope) && query == _workPreviewQuery) _workError(error);
    } finally {
      if (_current(scope) && query == _workPreviewQuery) {
        workLoading = false;
        _notify();
      }
    }
  }

  Future<void> loadRequirementOptions({int offset = 0}) async {
    if (!active || employeeId == null) return;
    final scope = _scope, draft = workEditor;
    try {
      final result = await repository.read(
        () => repository.api.listOnsiteRequirements(
          employeeId!,
          offset: offset,
          limit: 100,
        ),
      );
      if (!_current(scope) || draft != workEditor) return;
      requirementOptions = result;
      _notify();
    } catch (error) {
      if (_current(scope) && draft == workEditor) {
        failure = _failure(error);
        _notify();
      }
    }
  }

  Future<void> refreshWorkspace() async {
    if (workId != null) {
      await openWork(workKind, workId!, preserveEditor: true);
    } else if (requirements != null || tasks != null || workEditor != null) {
      await loadWork();
    } else {
      await refresh();
    }
  }

  Future<void> resolveRequirement(String requestId) async {
    if (!workCanWrite || !manager || requirement == null) return;
    final r = requirement!, scope = _scope, query = _workQuery;
    bool current() =>
        _current(scope) &&
        query == _workQuery &&
        requirement?.id == r.id &&
        requirement?.revision == r.revision;
    try {
      if (!await openRequest(requestId) || !current()) return;
      final snapshot = await repository.read(
        () => repository.api.getCalendar(employeeId!, r.from, r.to),
      );
      if (!_current(scope) ||
          query != _workQuery ||
          requirement?.revision != r.revision) {
        return;
      }
      final approved = snapshot!.effectiveDays
          .where(
            (d) =>
                d.sourceRequestId == requestId &&
                d.sourceDayId != null &&
                (d.location != WorkLocation.officeSwitzerland ||
                    d.availability != Availability.working),
          )
          .toList();
      selectedDays = approved.map((d) => d.sourceDayId!).toSet();
      await editRequest(EditorMode.proposal);
      if (!_current(scope) || query != _workQuery || editor == null) return;
      final input = editor!;
      editor = PlanningEditor(
        mode: EditorMode.proposal,
        requestId: input.requestId,
        parentRevisionId: input.parentRevisionId,
        requirementId: r.id,
        requirementRevision: r.revision,
        affected: input.affected,
        note: r.reason,
        days: input.days
            .map(
              (d) => d.copyWith(
                location: WorkLocation.officeSwitzerland,
                availability: Availability.working,
                cancel: false,
              ),
            )
            .toList(),
      );
      inputChanged();
    } catch (error) {
      if (current()) {
        failure = _failure(error);
        needsReview = true;
        _notify();
      }
    }
  }
}
