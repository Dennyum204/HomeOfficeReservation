import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/config/api_settings.dart';
import 'package:homeoffice_mobile/features/auth/auth_screen.dart';
import 'package:homeoffice_mobile/features/planning/planning_controller.dart';
import 'package:homeoffice_mobile/features/planning/planning_dates.dart';
import 'package:homeoffice_mobile/features/planning/planning_screen.dart';

const email = String.fromEnvironment('TEST_EMAIL');
const password = String.fromEnvironment('TEST_PASSWORD');
const managerEmail = String.fromEnvironment('TEST_MANAGER_EMAIL');
const managerPassword = String.fromEnvironment('TEST_MANAGER_PASSWORD');
String? selectedEmployee;
bool _surfaceConverted = false;
Future<void> screenshot(WidgetTester t, String name) async {
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  if (!_surfaceConverted) {
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
  await t.pump();
  expect(await binding.takeScreenshot(name), isNotEmpty);
}

PlanningController controller(WidgetTester t) =>
    t.widget<PlanningScreen>(find.byType(PlanningScreen)).controller;
Future<void> until(
  WidgetTester t,
  bool Function() predicate,
  String stage,
) async {
  for (var i = 0; i < 100 && !predicate(); i++) {
    await t.pump(const Duration(milliseconds: 200));
  }
  expect(predicate(), true, reason: stage);
  await t.pumpAndSettle();
}

Future<void> tap(WidgetTester t, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await t.pumpAndSettle();
  if (finder.evaluate().isEmpty) {
    // A previously visited detail may have retained a lower scroll position.
    // Search from the top so header actions and filters remain reachable.
    final scroll = find.byType(Scrollable).first;
    if (scroll.evaluate().isNotEmpty) {
      await t.drag(scroll, const Offset(0, 3000));
      await t.pumpAndSettle();
    }
  }
  if (finder.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      finder,
      280,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 70,
    );
  } else {
    await t.ensureVisible(finder);
  }
  await t.pumpAndSettle();
  await t.tap(finder);
  await t.pumpAndSettle();
}

Future<void> ready(WidgetTester t) => until(
  t,
  () =>
      find.byType(PlanningScreen).evaluate().isNotEmpty &&
      controller(t).initialized &&
      !controller(t).loading &&
      !controller(t).opening &&
      !controller(t).busy,
  'authorized planning state finishes loading',
);
Future<void> login(WidgetTester t, {bool manager = false}) async {
  final auth = t.widget<AuthScreen>(find.byType(AuthScreen)).controller;
  await until(t, () => !auth.busy, 'session restoration');
  if (auth.member != null) await tap(t, find.text('Terminar sessão'));
  await until(
    t,
    () => find.byKey(const Key('email')).evaluate().isNotEmpty,
    'logout clears the private workspace',
  );
  await t.enterText(
    find.byKey(const Key('email')),
    manager ? managerEmail : email,
  );
  await t.enterText(
    find.byKey(const Key('password')),
    manager ? managerPassword : password,
  );
  await tap(t, find.byKey(const Key('submit')));
  await ready(t);
}

Future<void> open(WidgetTester t, String id) async {
  await tap(t, find.byIcon(Icons.north_east));
  await ready(t);
  final c = controller(t);
  if (selectedEmployee != null && c.employeeId != selectedEmployee) {
    final member = c.employees.singleWhere(
      (m) => m.memberId == selectedEmployee,
    );
    await tap(t, find.byKey(ValueKey('employee-${c.employeeId}')));
    await tap(t, find.text(member.displayName).last);
    await ready(t);
  }
  await tap(t, find.byKey(Key('open-request-$id')));
  await ready(t);
  expect(controller(t).detail?.id, id);
}

Future<void> confirm(WidgetTester t, String key) async {
  await tap(t, find.byKey(Key(key)));
  expect(controller(t).review, isNotNull);
  await tap(t, find.byKey(const Key('planning-confirm')));
  await ready(t);
  expect(controller(t).journal, isNull);
  expect(controller(t).failure, PlanningFailure.none);
}

Future<ApiClient> client({bool manager = false}) async {
  final c = ApiClient(basePath: ApiSettings.baseUrl);
  final token = await AuthApi(c).loginToken(
    Credentials(
      email: manager ? managerEmail : email,
      password: manager ? managerPassword : password,
    ),
  );
  c.addDefaultHeader('Authorization', 'Bearer ${token!.accessToken}');
  return c;
}

Future<List<DateTime>> freeWeek(String employee) async {
  final c = await client();
  try {
    final from = shiftDay(planningToday('Europe/Zurich'), 35);
    final calendar = (await PlanningApi(c)
        .getCalendar(employee, from, shiftDay(from, 350)))!;
    final occupied = {
      ...calendar.effectiveDays
          .where((d) => d.origin != 'WeeklyPattern')
          .map((d) => dateKey(d.localDate)),
      ...calendar.pendingDays.map((d) => dateKey(d.day.localDate)),
    };
    for (var i = 0; i < 340; i++) {
      final date = shiftDay(from, i);
      if (date.weekday != 1) continue;
      final days = List.generate(5, (n) => shiftDay(date, n));
      if (days.every(
        (d) =>
            !occupied.contains(dateKey(d)) &&
            !calendar.requirements.any(
              (r) => !d.isBefore(r.from) && !d.isAfter(r.to),
            ),
      )) {
        return days;
      }
    }
    throw StateError('No free synthetic week; existing plans are preserved.');
  } finally {
    c.client.close();
  }
}

Future<void> calendarEvidence(
  String employee,
  List<DateTime> days, {
  required int approved,
  required int pending,
  bool manager = false,
}) async {
  final c = await client(manager: manager);
  try {
    final v = (await PlanningApi(c)
        .getCalendar(employee, days.first, days.last))!;
    expect(
      v.effectiveDays.where((d) => d.origin == 'ApprovedRequest'),
      hasLength(approved),
    );
    expect(v.pendingDays, hasLength(pending));
    expect(
      v.effectiveDays
          .where((d) => d.origin == 'ApprovedRequest')
          .every((d) => d.location == WorkLocation.remotePortugal),
      true,
    );
  } finally {
    c.client.close();
  }
}

Future<void> note(WidgetTester t, String value) async {
  final finder = find.byKey(const Key('editor-note'));
  if (finder.evaluate().isEmpty) {
    await t.scrollUntilVisible(finder, 300, maxScrolls: 70);
  }
  await t.ensureVisible(finder);
  await t.pumpAndSettle();
  await t.enterText(finder, value);
  FocusManager.instance.primaryFocus?.unfocus();
  await t.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android submits five, approves three, withdraws two and resolves a counterproposal over an approved revision',
    (t) async {
      expect(Platform.isAndroid, true);
      expect(
        [
          email,
          password,
          managerEmail,
          managerPassword,
        ].every((s) => s.isNotEmpty),
        true,
        reason: 'Private synthetic accounts required; no skip.',
      );
      app.main();
      await t.pumpAndSettle();
      await login(t);
      final employee = controller(t).actor;
      selectedEmployee = employee;
      final days = await freeWeek(employee);
      final marker =
          'Ensaio Android HO-010 ${DateTime.now().microsecondsSinceEpoch}';
      await tap(t, find.byIcon(Icons.north_east));
      await ready(t);
      await tap(t, find.byKey(const Key('planning-new-request')));
      await tap(t, find.byKey(const Key('editor-range')));
      await tap(t, find.byIcon(Icons.edit_outlined));
      final dialog = find.byType(DateRangePickerDialog);
      final fields = find.descendant(
        of: dialog,
        matching: find.byType(TextField),
      );
      expect(fields, findsNWidgets(2));
      String input(DateTime d) =>
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      await t.enterText(fields.at(0), input(days.first));
      await t.enterText(fields.at(1), input(days.last));
      final save = MaterialLocalizations.of(t.element(dialog)).okButtonLabel;
      await tap(t, find.descendant(of: dialog, matching: find.text(save)));
      await tap(t, find.byKey(const Key('editor-preview')));
      await until(
        t,
        () => find.byKey(const Key('editor-add-preview')).evaluate().isNotEmpty,
        'inclusive server date preview',
      );
      await tap(t, find.byKey(const Key('editor-add-preview')));
      expect(
        controller(t).editor!.days.map((d) => dateKey(d.localDate)),
        days.map(dateKey),
      );
      await note(t, marker);
      await confirm(t, 'editor-save');
      final request = controller(t).detail!.id;
      expect(controller(t).detail!.state, RequestState.draft);
      await confirm(t, 'request-submit');
      expect(
        controller(t).detail!.days
            .where((d) => d.decision == DayDecision.pending),
        hasLength(5),
      );

      await login(t, manager: true);
      await open(t, request);
      for (final d in days.skip(3)) {
        await tap(t, find.byKey(Key('select-${dateKey(d)}')));
      }
      expect(controller(t).chosen, hasLength(3));
      await confirm(t, 'request-approve');
      expect(
        controller(t).detail!.days
            .where((d) => d.decision == DayDecision.approved),
        hasLength(3),
      );
      expect(
        controller(t).detail!.days
            .where((d) => d.decision == DayDecision.pending),
        hasLength(2),
      );
      await calendarEvidence(
        employee,
        days,
        approved: 3,
        pending: 2,
        manager: true,
      );
      await t.ensureVisible(find.byKey(const Key('request-counts')));
      await t.pumpAndSettle();
      await screenshot(t, 'ho010-manager-partial');
      await login(t);
      await open(t, request);
      expect(controller(t).chosen, hasLength(2));
      await calendarEvidence(employee, days, approved: 3, pending: 2);
      await confirm(t, 'request-withdraw');
      expect(
        controller(t).detail!.days
            .where((d) => d.decision == DayDecision.withdrawn),
        hasLength(2),
      );
      await calendarEvidence(employee, days, approved: 3, pending: 0);
      await t.ensureVisible(find.byKey(const Key('request-counts')));
      await t.pumpAndSettle();
      await screenshot(t, 'ho010-employee-withdrawn');

      // A cancellation is only a proposed revision; the original approvals remain effective.
      await tap(t, find.byKey(Key('select-${dateKey(days.first)}')));
      await tap(t, find.byKey(const Key('request-cancel')));
      await ready(t);
      expect(controller(t).editor!.days.single.cancel, true);
      await note(t, '$marker — alteração pendente');
      await confirm(t, 'editor-save');
      await confirm(t, 'request-submit');
      final revision = controller(t).detail!.id;
      await calendarEvidence(employee, days, approved: 3, pending: 1);
      await login(t, manager: true);
      await open(t, revision);
      await tap(t, find.byKey(const Key('request-propose')));
      await ready(t);
      await note(t, '$marker — contraproposta sintética');
      await confirm(t, 'editor-save');
      final proposal = controller(t).proposals!.items.first;
      expect(proposal.state, ProposalState.open);
      await login(t);
      await open(t, revision);
      await tap(t, find.byKey(Key('accept-${proposal.id}')));
      await tap(t, find.byKey(const Key('planning-confirm')));
      await ready(t);
      final accepted = controller(t).detail!.id;
      expect(accepted, isNot(revision));
      expect(controller(t).detail!.state, RequestState.submitted);
      await calendarEvidence(employee, days, approved: 3, pending: 1);
      await login(t, manager: true);
      await open(t, accepted);
      await confirm(t, 'request-approve');
      await calendarEvidence(
        employee,
        days,
        approved: 2,
        pending: 0,
        manager: true,
      );
      await login(t);
      await open(t, accepted);
      expect(controller(t).detail!.days.single.decision, DayDecision.cancelled);
      await calendarEvidence(employee, days, approved: 2, pending: 0);
      // Only this run's newly created synthetic requests were mutated. No fixture/database reset.
    },
    timeout: const Timeout(Duration(minutes: 7)),
  );
}
