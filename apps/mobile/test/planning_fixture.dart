import 'dart:convert';

import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/auth/auth_controller.dart';
import 'package:homeoffice_mobile/features/planning/planning_controller.dart';
import 'package:homeoffice_mobile/features/planning/planning_repository.dart';
import 'package:homeoffice_mobile/features/planning/planning_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'auth_test.dart' show MemoryStore, json, profile, tokens;

class PlanningMemoryStore implements PlanningStore {
  String? value;
  bool fail = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String data) async {
    if (fail) throw StateError('simulated secure storage failure');
    value = data;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class PlanningFixture {
  PlanningFixture() {
    final client = ApiClient(basePath: 'http://localhost');
    client.client.close();
    client.client = MockClient(handle);
    auth = AuthController(client, MemoryStore());
  }
  late final AuthController auth;
  final store = PlanningMemoryStore();
  late PlanningController c;
  int version = 1;
  String actor = 'member';
  bool offline = false;
  final writes = <http.Request>[];
  Future<http.Response?> Function(http.Request)? intercept;
  RequestView get request => RequestView(
    acceptedProposalId: null,
    createdAt: DateTime.utc(2026, 9, 10),
    employeeId: 'member',
    id: 'request',
    note: 'Synthetic input',
    parentRevisionId: null,
    revision: 1,
    rootId: 'request',
    state: RequestState.draft,
    submittedAt: null,
    version: version,
  );
  Future<http.Response> handle(http.Request r) async {
    if (offline) throw http.ClientException('simulated disconnected transport');
    if (r.url.path.endsWith('/login') || r.url.path.endsWith('/refresh')) {
      return json(tokens);
    }
    if (r.method != 'GET') writes.add(r);
    final overridden = await intercept?.call(r);
    if (overridden != null) return overridden;
    final path = r.url.path;
    if (!path.contains('/planning/')) {
      return json({...profile, 'memberId': actor});
    }
    if (r.method != 'GET') {
      return json(
        MutationReceipt(
          contextId: 'request',
          version: version,
          calendarVersion: version,
          eventId: 'event',
        ),
      );
    }
    if (path.endsWith('/calendar')) {
      return json(
        CalendarView(
          calendarVersion: version,
          employeeId: actor,
          from: DateTime.parse(r.url.queryParameters['from']!),
          to: DateTime.parse(r.url.queryParameters['to']!),
          planningTimeZone: 'Europe/Zurich',
        ),
      );
    }
    if (path.endsWith('/requests')) {
      return json(
        RequestPage(
          calendarVersion: version,
          items: [request],
          nextOffset: null,
        ),
      );
    }
    if (path.endsWith('/comments')) return json(CommentPage(nextOffset: null));
    if (path.endsWith('/proposals')) {
      return json(ProposalPage(nextOffset: null));
    }
    return json(request);
  }

  Future<void> start() async {
    await auth.login('employee@test.example', 'simulated-password');
    c = PlanningController(PlanningRepository(auth), store);
    await c.initialize();
  }

  PlanningCommand draft({String note = 'Original intent'}) => c.prepare(
    PlanningOperation.createDraft,
    DraftInput(
      expectedCalendarVersion: c.calendar!.calendarVersion,
      expectedRequestVersion: null,
      parentRevisionId: null,
      note: note,
      days: [
        DayInput(
          localDate: DateTime(2027, 3, 28),
          location: WorkLocation.remotePortugal,
          availability: Availability.working,
        ),
      ],
    ),
  );
  Map<String, dynamic> get saved =>
      jsonDecode(store.value!) as Map<String, dynamic>;
  void dispose() {
    c.dispose();
    auth.dispose();
  }
}
