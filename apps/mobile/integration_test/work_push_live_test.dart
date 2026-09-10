// Explicit external acceptance only. Real Firebase configuration and authorized
// synthetic accounts; Android permission is configured on the selected test device.
// The denied phase verifies OS refusal without treating it as a user's consent.
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/features/notifications/push_coordinator.dart';
import 'package:homeoffice_mobile/features/notifications/push_gateway.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';

import 'planning_test.dart' as p;
import 'work_test.dart' as w;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'real Android notification permission and FCM work destinations',
    (t) async {
      expect(const bool.fromEnvironment('FCM_ENABLED'), true);
      app.main();
      await t.pumpAndSettle();
      await p.login(t);
      final employee = w.c(t).actor;
      final workspace = t.widget<WorkspaceScreen>(find.byType(WorkspaceScreen));
      final push = workspace.push!, inbox = workspace.inbox!;
      final denied =
          const String.fromEnvironment('TEST_CORE_PHASE') == 'denied';
      final permission =
          (await FirebaseMessaging.instance.getNotificationSettings())
              .authorizationStatus;
      if (denied) {
        expect(permission, AuthorizationStatus.denied);
        await p.tap(t, find.byIcon(Icons.notifications_outlined));
        await p.until(
          t,
          () => !inbox.loading && inbox.page != null,
          'real inbox with notification permission denied',
        );
        expect(inbox.error, false);
        expect(inbox.page!.items, isNotEmpty);
        final item = inbox.page!.items.first;
        await p.tap(
          t,
          find.descendant(
            of: find.byKey(Key('notification-${item.id}')),
            matching: find.text('Abrir notificação'),
          ),
        );
        await w.ready(t);
        expect(w.c(t).workId != null || w.c(t).detail != null, true);
        expect(
          (await FirebaseMessaging.instance.getNotificationSettings())
              .authorizationStatus,
          AuthorizationStatus.denied,
        );
        await p.screenshot(t, 'ho011-android-permission-denied-inbox');
        return;
      }
      expect(
        permission,
        AuthorizationStatus.authorized,
        reason: 'Configure permission on the explicitly selected test emulator before this live test.',
      );
      await p.tap(t, find.byIcon(Icons.settings_outlined));
      await p.until(
        t,
        () => [PushStatus.off, PushStatus.enabled].contains(push.status),
        'private Firebase initialization',
      );
      if (!push.enabled) {
        await p.tap(t, find.text('Ativar alertas neste dispositivo'));
      }
      await p.until(
        t,
        () => push.status == PushStatus.enabled,
        'real FCM registration',
      );
      final received = <String>[];
      final subscription = FirebaseMessaging.onMessage.listen((message) {
        final id = notificationLink(message.data);
        if (id != null) received.add(id);
      });
      try {
        final day = (await p.freeWeek(employee)).first;
        final onsite = await w.api((a) async {
          final v = (await a.getCalendar(employee, day, day))!.calendarVersion;
          return (await a.createOnsiteRequirement(
            employee,
            w.key(),
            OnsiteInput(
              expectedCalendarVersion: v,
              expectedVersion: null,
              from: day,
              to: day,
              reason: 'Ensaio FCM HO-011 — presença',
              location: 'Oficina de teste',
              reference: 'Sintético',
            ),
          ))!;
        }, manager: true);
        await p.until(
          t,
          () =>
              received.isNotEmpty &&
              find.byType(SnackBar).evaluate().isNotEmpty,
          'actual onsite FCM callback and foreground alert',
        );
        await p.tap(
          t,
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Abrir notificação'),
          ),
        );
        await w.ready(t);
        expect(w.c(t).requirement!.id, onsite.contextId);
        expect(w.c(t).requirement!.readAt, isNull);
        final auth = w.c(t).repository.auth;
        final notification = (await auth.readAuthenticated(
          () => NotificationsApi(auth.client).getNotification(received.last),
        ))!;
        expect(notification.readAt, isNull);
        expect(notification.destination!.resourceId, onsite.contextId);
        final calendarBefore = (await w.calendar(employee, day)).effectiveDays;
        await p.screenshot(t, 'ho011-live-onsite-foreground');
        received.clear();
        final task = await w.api((a) async {
          final v = (await a.getCalendar(employee, day, day))!.calendarVersion;
          return (await a.createAssignedTask(
            employee,
            w.key(),
            TaskInput(
              expectedCalendarVersion: v,
              expectedVersion: null,
              title: 'Ensaio FCM HO-011 — tarefa',
              description: 'Ensaio de destino autenticado',
              deadline: day,
              state: AssignedTaskState.todo,
              requiresOnsite: true,
              requirementId: onsite.contextId,
            ),
          ))!;
        }, manager: true);
        await p.until(
          t,
          () =>
              received.isNotEmpty &&
              find.byType(SnackBar).evaluate().isNotEmpty,
          'actual task FCM callback and foreground alert',
        );
        await p.tap(
          t,
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Abrir notificação'),
          ),
        );
        await w.ready(t);
        expect(w.c(t).task!.id, task.contextId);
        expect(w.c(t).task!.state, AssignedTaskState.todo);
        expect((await w.calendar(employee, day)).effectiveDays, calendarBefore);
        final taskNote = (await auth.readAuthenticated(
          () => NotificationsApi(auth.client).getNotification(received.last),
        ))!;
        expect(taskNote.readAt, isNull);
        await t.ensureVisible(find.byKey(const Key('work-detail-title')));
        await t.pumpAndSettle();
        await p.screenshot(t, 'ho011-live-task-foreground');
      } finally {
        await subscription.cancel();
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
