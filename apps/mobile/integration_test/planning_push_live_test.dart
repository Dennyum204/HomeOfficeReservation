import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/features/notifications/push_coordinator.dart';
import 'package:homeoffice_mobile/features/notifications/push_gateway.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';

import 'planning_test.dart' as flow;

// External manual test: real configured provider, prior Android consent, synthetic accounts.
// Never part of ordinary setup or core CI.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'real FCM decision alert opens current authorized Android request without making another decision',
    (tester) async {
      expect(const bool.fromEnvironment('FCM_ENABLED'), true);
      app.main();
      await tester.pumpAndSettle();
      await flow.login(tester);
      final employee = flow.controller(tester).actor;
      await flow.tap(tester, find.byIcon(Icons.settings_outlined));
      PushCoordinator push() =>
          tester.widget<WorkspaceScreen>(find.byType(WorkspaceScreen)).push!;
      await flow.until(
        tester,
        () => [PushStatus.off, PushStatus.enabled].contains(push().status),
        'existing Firebase configuration initializes',
      );
      expect(
        (await FirebaseMessaging.instance.getNotificationSettings())
            .authorizationStatus,
        AuthorizationStatus.authorized,
        reason: 'The owner must already have granted Android permission; this test does not grant consent.',
      );
      if (!push().enabled) {
        await flow.tap(tester, find.text('Ativar alertas neste dispositivo'));
      }
      await flow.until(
        tester,
        () => push().status == PushStatus.enabled,
        'real FCM device registration',
      );
      String? received;
      final subscription = FirebaseMessaging.onMessage.listen((message) {
        final id = notificationLink(message.data);
        if (id != null) received = id;
      });
      try {
        final dates = await flow.freeWeek(employee);
        final client = await flow.client();
        late String requestId;
        try {
          final api = PlanningApi(client);
          final calendar = (await api.getCalendar(
            employee,
            dates.first,
            dates.first,
          ))!;
          final key = 'ho010-live-${DateTime.now().microsecondsSinceEpoch}';
          final draft = (await api.createPlanningDraft(
            employee,
            '$key-draft',
            DraftInput(
              expectedCalendarVersion: calendar.calendarVersion,
              expectedRequestVersion: null,
              parentRevisionId: null,
              note: 'Ensaio FCM de decisão HO-010',
              days: [
                DayInput(
                  localDate: dates.first,
                  location: WorkLocation.remotePortugal,
                  availability: Availability.working,
                ),
              ],
            ),
          ))!;
          requestId = draft.contextId;
          await api.submitPlanningRequest(
            employee,
            requestId,
            '$key-submit',
            SubmitInput(
              expectedCalendarVersion: draft.calendarVersion,
              expectedRequestVersion: draft.version,
            ),
          );
        } finally {
          client.client.close();
        }
        final manager = await flow.client(manager: true);
        try {
          final api = PlanningApi(manager);
          final request = (await api.getPlanningRequest(employee, requestId))!;
          final calendar = (await api.getCalendar(
            employee,
            dates.first,
            dates.first,
          ))!;
          await api.decidePlanningDays(
            employee,
            requestId,
            'ho010-live-decision-${DateTime.now().microsecondsSinceEpoch}',
            DecisionInput(
              expectedCalendarVersion: calendar.calendarVersion,
              expectedRequestVersion: request.version,
              days: [
                SelectedDay(
                  dayId: request.days.single.id,
                  expectedVersion: request.days.single.version,
                ),
              ],
              approve: true,
              reason: 'Ensaio sintético de abertura de notificação',
            ),
          );
        } finally {
          manager.client.close();
        }
        await flow.until(
          tester,
          () => received != null && find.byType(SnackBar).evaluate().isNotEmpty,
          'actual provider callback and generic foreground alert',
        );
        await flow.tap(
          tester,
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Abrir notificação'),
          ),
        );
        await flow.ready(tester);
        expect(flow.controller(tester).detail!.id, requestId);
        expect(
          flow.controller(tester).detail!.days.single.decision,
          DayDecision.approved,
        );
        final auth = flow.controller(tester).repository.auth;
        final notification = (await auth.readAuthenticated(
          () => NotificationsApi(auth.client).getNotification(received!),
        ))!;
        expect(notification.destination!.resourceId, requestId);
        expect(
          notification.readAt,
          isNull,
          reason: 'Opening is not a read acknowledgement or approval.',
        );
        await tester.ensureVisible(find.byKey(const Key('request-counts')));
        await tester.pumpAndSettle();
        await flow.screenshot(tester, 'ho010-live-decision-open');
      } finally {
        await subscription.cancel();
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
