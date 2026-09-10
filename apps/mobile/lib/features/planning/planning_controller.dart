import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:homeoffice_api/api.dart';

import 'planning_dates.dart';
import 'planning_editor.dart';
import 'planning_repository.dart';
import 'planning_store.dart';

enum PlanningFailure {
  none,
  network,
  forbidden,
  missing,
  stale,
  conflict,
  invalid,
  limited,
  storage,
  uncertain,
}

class PlanningReview {
  PlanningReview(this.command, this.title, this.lines);
  final PlanningCommand command;
  final String title;
  final List<String> lines;
}

class PlanningController extends ChangeNotifier {
  PlanningController(this.repository, this.store)
    : actor = repository.auth.member!.memberId,
      _session = repository.auth.sessionGeneration {
    repository.auth.onPrivateStateClearing = clearSession;
  }
  final PlanningRepository repository;
  final PlanningStore store;
  final String actor;
  final int _session;
  bool _disposed = false, _cleared = false;
  int _scope = 0, _query = 0, _detailQuery = 0, _previewQuery = 0;
  Timer? _saveTimer;
  Future<void>? _initializing;
  String? failedRequest;
  int commentEditGeneration = 0;
  List<MemberProfile> employees = [];
  String? employeeId;
  DateTime month = planningToday('Europe/Zurich');
  DateTime selectedDate = planningToday('Europe/Zurich');
  CalendarView? calendar;
  RequestPage? requests;
  RequestView? detail;
  CommentPage? comments;
  ProposalPage? proposals;
  int offset = 0, commentOffset = 0, proposalOffset = 0;
  RequestState? filter;
  Set<String> selectedDays = {};
  bool loading = false,
      opening = false,
      busy = false,
      initialized = false,
      needsReview = false;
  bool dataStale = false;
  PlanningFailure failure = PlanningFailure.none;
  PlanningFailure readFailure = PlanningFailure.none;
  String? problemCode;
  PlanningCommand? journal;
  PlanningEditor? editor;
  PlanningReview? review;
  bool get hasSavedEditor => _editors.containsKey(employeeId);
  final Map<String, PlanningEditor> _editors = {};
  final Map<String, String> reasons = {}, commentDrafts = {};
  DateTime? updatedAt;
  MutationReceipt? lastReceipt;
  bool get active =>
      !_disposed &&
      !_cleared &&
      repository.auth.member?.memberId == actor &&
      repository.auth.sessionGeneration == _session;
  bool get own => employeeId == actor;
  bool get manager => !own && repository.auth.member?.isManager == true;
  bool get locked => busy || journal != null;
  bool get canWrite =>
      active &&
      initialized &&
      !locked &&
      !needsReview &&
      !loading &&
      !opening &&
      !dataStale &&
      calendar != null;
  MemberProfile? get employee =>
      employees.where((m) => m.memberId == employeeId).firstOrNull;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool _current(int scope) => active && scope == _scope;

  Future<void> initialize() =>
      _initializing ??= _initialize().whenComplete(() => _initializing = null);

  Future<void> _initialize() async {
    loading = true;
    _notify();
    try {
      final saved = await store.read();
      if (!active) return;
      if (saved != null) {
        final value = jsonDecode(saved) as Map<String, dynamic>;
        if (value['actor'] == actor) {
          employeeId = value['employee'] as String?;
          for (final entry in (value['editors'] as Map? ?? {}).entries) {
            _editors[entry.key as String] = PlanningEditor.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            );
          }
          reasons.addAll(
            Map<String, String>.from(value['reasons'] as Map? ?? {}),
          );
          commentDrafts.addAll(
            Map<String, String>.from(value['comments'] as Map? ?? {}),
          );
          if (value['journal'] != null) {
            final restored = PlanningCommand.fromJson(
              Map<String, dynamic>.from(value['journal'] as Map),
            );
            if (restored.actor != actor) throw const FormatException();
            journal = restored;
            employeeId = restored.employee;
            failure = PlanningFailure.uncertain;
          }
        } else {
          await store.clear();
        }
      }
      final values = await repository.employees();
      if (!active) return;
      employees = values;
      if (!values.any((e) => e.memberId == employeeId)) {
        if (journal != null) {
          readFailure = PlanningFailure.forbidden;
          initialized = true;
          return;
        }
        employeeId = values.firstOrNull?.memberId;
      }
      initialized = true;
      await refresh();
    } catch (error) {
      if (active) readFailure = _failure(error);
    } finally {
      if (active) {
        loading = false;
        _notify();
      }
    }
  }

  Future<void> persist() async {
    _saveTimer?.cancel();
    if (!active) return;
    final value = jsonEncode({
      'actor': actor,
      'employee': employeeId,
      'journal': journal?.toJson(),
      'editors': _editors,
      'reasons': reasons,
      'comments': commentDrafts,
    });
    await store.write(value);
  }

  void inputChanged() {
    if (!active) return;
    if (editor != null && employeeId != null) _editors[employeeId!] = editor!;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 250), () async {
      try {
        await persist();
      } catch (_) {
        if (active) {
          failure = PlanningFailure.storage;
          _notify();
        }
      }
    });
    _notify();
  }

  Future<void> clearSession(bool discard) async {
    _saveTimer?.cancel();
    final saved = jsonEncode({
      'actor': actor,
      'employee': employeeId,
      'journal': journal?.toJson(),
      'editors': _editors,
      'reasons': reasons,
      'comments': commentDrafts,
    });
    _cleared = true;
    _scope++;
    _query++;
    _detailQuery++;
    _previewQuery++;
    employees = [];
    employeeId = null;
    calendar = null;
    requests = null;
    detail = null;
    comments = null;
    proposals = null;
    editor = null;
    journal = null;
    review = null;
    _editors.clear();
    reasons.clear();
    commentDrafts.clear();
    selectedDays.clear();
    _notify();
    if (discard) {
      await store.clear();
    } else {
      await store.write(saved);
    }
  }

  Future<void> selectEmployee(String id) async {
    if (locked || !employees.any((m) => m.memberId == id) || id == employeeId) {
      return;
    }
    await persist();
    if (!active) return;
    _scope++;
    _detailQuery++;
    _previewQuery++;
    employeeId = id;
    calendar = null;
    requests = null;
    detail = null;
    editor = null;
    comments = null;
    proposals = null;
    selectedDays = {};
    offset = 0;
    filter = null;
    needsReview = false;
    failure = PlanningFailure.none;
    await refresh();
  }

  Future<void> refresh() async {
    if (!active || employeeId == null) return;
    final scope = _scope, query = ++_query, target = employeeId!;
    loading = true;
    readFailure = PlanningFailure.none;
    _notify();
    final grid = monthGrid(month);
    try {
      final values = await Future.wait([
        repository.read(
          () => repository.api.getCalendar(target, grid.first, grid.last),
        ),
        repository.read(
          () => repository.api.listPlanningRequests(
            target,
            offset: offset,
            limit: 20,
            state: filter,
          ),
        ),
      ]);
      if (!_current(scope) || query != _query) return;
      calendar = values[0] as CalendarView?;
      requests = values[1] as RequestPage?;
      dataStale =
          calendar == null ||
          requests == null ||
          calendar!.calendarVersion != requests!.calendarVersion;
      if (dataStale) readFailure = PlanningFailure.stale;
      updatedAt = DateTime.now();
    } catch (error) {
      if (_current(scope) && query == _query) {
        readFailure = _failure(error);
        dataStale = true;
        if (readFailure == PlanningFailure.forbidden ||
            readFailure == PlanningFailure.missing) {
          calendar = null;
          requests = null;
          detail = null;
          comments = null;
          proposals = null;
        }
      }
    } finally {
      if (_current(scope) && query == _query) {
        loading = false;
        _notify();
      }
    }
  }

  Future<void> goMonth(DateTime value) async {
    month = DateTime(value.year, value.month);
    await refresh();
  }

  Future<void> today() async {
    selectedDate = planningToday(calendar?.planningTimeZone ?? 'Europe/Zurich');
    await goMonth(selectedDate);
  }

  void selectDate(DateTime value) {
    selectedDate = dayOnly(value);
    _notify();
  }

  Future<void> selectFilter(RequestState? value) async {
    filter = value;
    offset = 0;
    requests = null;
    await refresh();
  }

  Future<void> page(int value) async {
    offset = value;
    requests = null;
    await refresh();
  }

  Future<bool> openRequest(
    String id, {
    String? target,
    bool preserveSelection = false,
  }) async {
    if (target != null && target != employeeId) {
      if (locked || !employees.any((m) => m.memberId == target)) {
        failure = PlanningFailure.forbidden;
        _notify();
        return false;
      }
      await selectEmployee(target);
    }
    if (!active || employeeId == null) return false;
    failedRequest = null;
    if (!needsReview && journal == null) failure = PlanningFailure.none;
    final scope = _scope, query = ++_detailQuery, employee = employeeId!;
    final same = detail?.id == id;
    if (!same) {
      detail = null;
      comments = null;
      proposals = null;
      commentOffset = 0;
      proposalOffset = 0;
    }
    opening = true;
    _notify();
    try {
      final values = await Future.wait([
        repository.read(() => repository.api.getPlanningRequest(employee, id)),
        repository.read(
          () => repository.api.listPlanningComments(
            employee,
            id,
            offset: commentOffset,
            limit: 20,
          ),
        ),
        repository.read(
          () => repository.api.listCounterproposals(
            employee,
            id,
            offset: proposalOffset,
            limit: 20,
          ),
        ),
      ]);
      if (!_current(scope) || query != _detailQuery) return false;
      detail = values[0] as RequestView?;
      comments = values[1] as CommentPage?;
      proposals = values[2] as ProposalPage?;
      if (!preserveSelection || !same) {
        selectedDays = detail!.days
            .where((d) => d.decision == DayDecision.pending)
            .map((d) => d.id)
            .toSet();
      } else {
        selectedDays = selectedDays.intersection(
          detail!.days.map((d) => d.id).toSet(),
        );
      }
      await refresh();
      return _current(scope) && query == _detailQuery;
    } catch (error) {
      if (_current(scope) && query == _detailQuery) {
        failure = _failure(error);
        failedRequest = id;
        detail = null;
        comments = null;
        proposals = null;
      }
      return false;
    } finally {
      if (_current(scope) && query == _detailQuery) {
        opening = false;
        _notify();
      }
    }
  }

  void closeDetail() {
    _detailQuery++;
    failedRequest = null;
    detail = null;
    opening = false;
    _notify();
  }

  void selectRequestedDay(String id, bool selected) {
    if (selected) {
      selectedDays.add(id);
    } else {
      selectedDays.remove(id);
    }
    _notify();
  }

  List<RequestedDayView> get chosen =>
      detail?.days.where((d) => selectedDays.contains(d.id)).toList() ?? [];
  List<SelectedDay> get chosenVersions => chosen
      .map((d) => SelectedDay(dayId: d.id, expectedVersion: d.version))
      .toList();
  void newEditor() {
    editor = _editors[employeeId] ?? PlanningEditor(mode: EditorMode.create);
    inputChanged();
    if (editor!.requestId != null && detail?.id != editor!.requestId) {
      unawaited(openRequest(editor!.requestId!));
    }
  }

  void closeEditor({bool discard = false}) {
    if (locked) return;
    if (discard) _editors.remove(employeeId);
    editor = null;
    inputChanged();
  }

  Future<void> editRequest(
    EditorMode mode, {
    bool cancel = false,
    ProposalView? proposal,
  }) async {
    if (!canWrite || detail == null) return;
    final source = detail!, scope = _scope;
    final selected = mode == EditorMode.edit ? source.days : chosen;
    var days =
        (proposal?.days ??
        selected
            .map(
              (d) => DayInput(
                localDate: d.localDate,
                location: d.location,
                availability: d.availability,
                cancel: d.cancel,
                baseDayId: d.baseDayId,
                basePlanVersion: d.basePlanVersion,
              ),
            )
            .toList());
    opening = true;
    _notify();
    try {
      final approved = selected
          .where((d) => d.decision == DayDecision.approved)
          .toList();
      if (mode != EditorMode.edit && proposal == null && approved.isNotEmpty) {
        final dates = approved.map((d) => d.localDate).toList()..sort();
        final current = (await repository.read(
          () =>
              repository.api.getCalendar(employeeId!, dates.first, dates.last),
        ))!;
        days = days.map((d) {
          final original = approved
              .where((a) => sameDay(a.localDate, d.localDate))
              .firstOrNull;
          if (original == null) return d;
          final effective = current.effectiveDays
              .where((e) => e.sourceDayId == original.id)
              .firstOrNull;
          if (effective == null) throw ApiException(412, '');
          return d.copyWith(
            baseDayId: original.id,
            basePlanVersion: effective.version,
            cancel: cancel,
            location: cancel ? WorkLocation.unplanned : d.location,
            availability: cancel ? Availability.working : d.availability,
          );
        }).toList();
      }
      if (!_current(scope) || detail?.id != source.id) return;
      editor = PlanningEditor(
        mode: mode,
        requestId: source.id,
        parentRevisionId: source.parentRevisionId,
        proposalId: proposal?.id,
        requirementId: proposal?.requirementId,
        requirementRevision: proposal?.requirementRevision,
        affected: selected
            .map((d) => SelectedDay(dayId: d.id, expectedVersion: d.version))
            .toList(),
        days: days,
        note: proposal?.reason ?? (mode == EditorMode.edit ? source.note : ''),
      );
      inputChanged();
    } catch (error) {
      if (_current(scope)) {
        failure = _failure(error);
        needsReview = true;
      }
    } finally {
      if (_current(scope)) {
        opening = false;
        _notify();
      }
    }
  }

  Future<List<DateTime>?> preview(
    DateTime from,
    DateTime to,
    bool weekends,
  ) async {
    final scope = _scope, query = ++_previewQuery;
    try {
      final result = await repository.read(
        () => repository.api.previewPlanningDates(
          from,
          to,
          includeWeekends: weekends,
        ),
      );
      return _current(scope) && query == _previewQuery
          ? result!.days.map((d) => d.localDate).toList()
          : null;
    } catch (error) {
      if (_current(scope) && query == _previewQuery) {
        failure = _failure(error);
        _notify();
      }
      return null;
    }
  }

  PlanningCommand prepare(
    PlanningOperation op,
    Object dto, {
    String? request,
    String? proposal,
  }) => PlanningCommand.prepare(
    actor,
    employeeId!,
    op,
    dto,
    request: request,
    proposal: proposal,
  );
  void reviewCommand(
    PlanningCommand command,
    String title,
    List<String> lines,
  ) {
    if (!canWrite) return;
    review = PlanningReview(command, title, lines);
    _notify();
  }

  void closeReview() {
    if (!busy) {
      review = null;
      _notify();
    }
  }

  Future<void> confirmReview() async {
    final value = review;
    if (value == null) return;
    if (await run(value.command) || needsReview) {
      review = null;
      _notify();
    }
  }

  Future<bool> run(PlanningCommand command) async {
    if (!canWrite || command.actor != actor || command.employee != employeeId) {
      return false;
    }
    busy = true;
    failure = PlanningFailure.none;
    _notify();
    journal = command;
    try {
      await persist();
    } catch (_) {
      if (active) {
        journal = null;
        busy = false;
        failure = PlanningFailure.storage;
        _notify();
      }
      return false;
    }
    if (!active) return false;
    return _execute(command);
  }

  Future<bool> recover() async {
    if (!active || busy || journal == null) return false;
    busy = true;
    _notify();
    return _execute(journal!);
  }

  Future<bool> _execute(PlanningCommand command) async {
    final scope = _scope;
    try {
      final receipt = await repository.execute(command);
      if (!_current(scope)) return false;
      lastReceipt = receipt;
      // Persist acknowledgement before permitting a new intent. If storage fails,
      // replay remains safe because the original key and payload are retained.
      journal = null;
      if ({
        PlanningOperation.createDraft,
        PlanningOperation.editDraft,
        PlanningOperation.propose,
        PlanningOperation.reviseProposal,
      }.contains(command.operation)) {
        _editors.remove(command.employee);
        editor = null;
      }
      if (command.operation == PlanningOperation.comment) {
        commentDrafts.remove(command.request);
        commentEditGeneration++;
      }
      await persist();
      failure = PlanningFailure.none;
      needsReview = false;
      final id =
          {
            PlanningOperation.propose,
            PlanningOperation.reviseProposal,
          }.contains(command.operation)
          ? command.request!
          : receipt.contextId;
      await openRequest(id);
      return true;
    } catch (error) {
      if (!_current(scope)) return false;
      final status = _httpStatus(error);
      if (status >= 400 && status < 500) {
        journal = null;
        failure = _failure(error);
        problemCode = _problem(error);
        try {
          await persist();
        } catch (_) {
          failure = PlanningFailure.storage;
        }
        if ({409, 412, 428}.contains(status)) {
          needsReview = true;
          final id = detail?.id;
          await refresh();
          if (id != null) await openRequest(id, preserveSelection: true);
        }
      } else {
        journal = command;
        failure = PlanningFailure.uncertain;
      }
      return false;
    } finally {
      if (_current(scope)) {
        busy = false;
        _notify();
      }
    }
  }

  void reviewed() {
    if (!dataStale && !loading && !opening) {
      needsReview = false;
      failure = PlanningFailure.none;
      problemCode = null;
      _notify();
    }
  }

  PlanningFailure _failure(Object error) {
    final code = _httpStatus(error);
    return switch (code) {
      401 || 403 => PlanningFailure.forbidden,
      404 => PlanningFailure.missing,
      409 => PlanningFailure.conflict,
      412 || 428 => PlanningFailure.stale,
      400 || 422 => PlanningFailure.invalid,
      429 => PlanningFailure.limited,
      _ => PlanningFailure.network,
    };
  }

  // The generated client wraps transport exceptions in ApiException(400).
  // Only a response without an inner exception proves a server rejection.
  int _httpStatus(Object error) =>
      error is ApiException && error.innerException == null ? error.code : 0;

  String? _problem(Object error) {
    try {
      return (jsonDecode((error as ApiException).message ?? '{}')
              as Map)['code']
          as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _disposed = true;
    _scope++;
    if (repository.auth.onPrivateStateClearing == clearSession) {
      repository.auth.onPrivateStateClearing = null;
    }
    super.dispose();
  }
}
