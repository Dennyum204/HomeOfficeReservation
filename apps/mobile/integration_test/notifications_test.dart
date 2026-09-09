import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/main.dart' as app;
import 'package:homeoffice_mobile/config/api_settings.dart';
import 'package:homeoffice_mobile/features/auth/auth_screen.dart';
import 'package:homeoffice_mobile/features/auth/token_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android inbox reads a real PostgreSQL worker event without deciding the request',
    (tester) async {
      expect(
        Platform.isAndroid,
        isTrue,
        reason: 'This HO-007 integration test targets Android only.',
      );
      const email = String.fromEnvironment('TEST_EMAIL');
      const password = String.fromEnvironment('TEST_PASSWORD');
      const managerEmail = String.fromEnvironment('TEST_MANAGER_EMAIL');
      const managerPassword = String.fromEnvironment('TEST_MANAGER_PASSWORD');
      expect(
        [
          email,
          password,
          managerEmail,
          managerPassword,
        ].every((s) => s.isNotEmpty),
        isTrue,
        reason: 'Private synthetic account configuration is required; no skip.',
      );
      final client = ApiClient(basePath: ApiSettings.baseUrl);
      final token = await AuthApi(client)
          .loginToken(Credentials(email: email, password: password));
      client.addDefaultHeader('Authorization', 'Bearer ${token!.accessToken}');
      final employee = (await AccessApi(client).getCurrentMember())!.memberId;
      final planning = PlanningApi(client);
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day + 40);
      final calendar = (await planning.getCalendar(
        employee,
        from,
        from.add(const Duration(days: 300)),
      ))!;
      final occupied = {
        ...calendar.effectiveDays
            .where((d) => d.origin != 'WeeklyPattern')
            .map((d) => d.localDate),
        ...calendar.pendingDays.map((d) => d.day.localDate),
      };
      DateTime? date;
      for (var i = 0; i < 300; i++) {
        final d = DateTime(from.year, from.month, from.day + i);
        if (d.weekday <= 5 &&
            !occupied.contains(d) &&
            !calendar.requirements.any(
              (r) => !d.isBefore(r.from) && !d.isAfter(r.to),
            )) {
          date = d;
          break;
        }
      }
      expect(
        date,
        isNotNull,
        reason: 'Use a free synthetic date; preserve existing plans.',
      );
      final key =
          'android-notification-${DateTime.now().microsecondsSinceEpoch}';
      final draft = (await planning.createPlanningDraft(
        employee,
        '$key-draft',
        DraftInput(
          expectedCalendarVersion: calendar.calendarVersion,
          expectedRequestVersion: null,
          parentRevisionId: null,
          note: 'Android notification integration',
          days: [
            DayInput(
              availability: Availability.working,
              localDate: date!,
              location: WorkLocation.remotePortugal,
            ),
          ],
        ),
      ))!;
      await planning.submitPlanningRequest(
        employee,
        draft.contextId,
        '$key-submit',
        SubmitInput(
          expectedCalendarVersion: draft.calendarVersion,
          expectedRequestVersion: draft.version,
        ),
      );
      client.client.close();
      await SecureTokenStore(ApiSettings.baseUrl).clear();
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('email')), managerEmail);
      await tester.enterText(
        find.byKey(const Key('password')),
        managerPassword,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('submit')));
      await tester.tap(find.byKey(const Key('submit')));
      for (
        var i = 0;
        i < 40 && find.text('Terminar sessão').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(find.text('Terminar sessão'), findsOneWidget);
      final auth = tester
          .widget<AuthScreen>(find.byType(AuthScreen))
          .controller;
      final notifications = NotificationsApi(auth.client);
      NotificationView? item;
      for (var i = 0; i < 30 && item == null; i++) {
        final page = (await auth.readAuthenticated(
          () => notifications.listNotifications(limit: 100),
        ))!;
        for (final candidate in page.items) {
          if (candidate.destination?.resourceId == draft.contextId) {
            item = candidate;
          }
        }
        if (item == null) await tester.pump(const Duration(seconds: 1));
      }
      expect(
        item,
        isNotNull,
        reason: 'The actual worker must deliver the submitted event.',
      );
      expect(item!.readAt, isNull);
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();
      for (
        var i = 0;
        i < 30 && find.byKey(Key('notification-${item.id}')).evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      final card = find.byKey(Key('notification-${item.id}'));
      expect(card, findsOneWidget);
      final before = (await auth.readAuthenticated(
        () =>
            PlanningApi(auth.client)
                .getPlanningRequest(employee, draft.contextId),
      ))!;
      final unread = (await auth.readAuthenticated(
        () => notifications.getNotificationUnreadCount(),
      ))!.unreadCount;
      await tester.ensureVisible(find.byKey(Key('read-${item.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('read-${item.id}')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 20; i++) {
        final current = (await auth.readAuthenticated(
          () => notifications.getNotification(item!.id),
        ))!;
        if (current.readAt != null) break;
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(
        (await auth.readAuthenticated(
          () => notifications.getNotificationUnreadCount(),
        ))!.unreadCount,
        unread - 1,
      );
      expect(
        await auth.readAuthenticated(
          () =>
              PlanningApi(auth.client)
                  .getPlanningRequest(employee, draft.contextId),
        ),
        before,
      );
      final open = find.descendant(
        of: card,
        matching: find.text('Abrir notificação'),
      );
      await tester.ensureVisible(open);
      await tester.pumpAndSettle();
      await tester.tap(open);
      await tester.pumpAndSettle();
      for (
        var i = 0;
        i < 20 &&
            find.byKey(const Key('notification-context')).evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(find.text(draft.contextId), findsOneWidget);
      expect(
        find.textContaining('Consulte e trate este assunto na Web.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Terminar sessão'));
      await tester.pumpAndSettle();
      expect(find.text(draft.contextId), findsNothing);
      expect(find.text('Entre no seu espaço'), findsOneWidget);
      // No Firebase credentials/provider are used. This proves native inbox/API/worker connectivity only.
    },
  );
}
