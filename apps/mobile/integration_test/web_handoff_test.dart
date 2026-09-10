import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;

import 'planning_test.dart' as flow;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'a real Web-created request is decided in Android and both Android accounts converge',
    (tester) async {
      const id = String.fromEnvironment('TEST_WEB_REQUEST');
      const employee = String.fromEnvironment('TEST_WEB_EMPLOYEE');
      const date = String.fromEnvironment('TEST_WEB_DATE');
      expect(
        [id, employee, date].every((s) => s.isNotEmpty),
        true,
        reason: 'Run the Web create handoff first and supply its private state; no skip.',
      );
      flow.selectedEmployee = employee;
      app.main();
      await tester.pumpAndSettle();
      await flow.login(tester, manager: true);
      await flow.open(tester, id);
      expect(flow.controller(tester).employeeId, employee);
      expect(
        flow.controller(tester).detail!.days.single.decision,
        DayDecision.pending,
      );
      await flow.confirm(tester, 'request-approve');
      final dates = [DateTime.parse(date)];
      await flow.calendarEvidence(
        employee,
        dates,
        approved: 1,
        pending: 0,
        manager: true,
      );
      await flow.login(tester);
      await flow.open(tester, id);
      expect(
        flow.controller(tester).detail!.days.single.decision,
        DayDecision.approved,
      );
      await flow.calendarEvidence(employee, dates, approved: 1, pending: 0);
      await flow.tap(tester, find.byIcon(Icons.calendar_month_outlined));
      await flow.controller(tester).goMonth(dates.single);
      flow.controller(tester).selectDate(dates.single);
      await flow.ready(tester);
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
