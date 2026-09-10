import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/notifications/inbox_controller.dart';
import 'package:homeoffice_mobile/features/notifications/notification_repository.dart';
import 'package:homeoffice_mobile/features/planning/planning_controller.dart';
import 'package:homeoffice_mobile/features/work/work_screen.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';
import 'package:homeoffice_mobile/l10n/generated/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

import 'auth_test.dart' show json;
import 'work_fixture.dart';

Widget localized(Widget child, {double scale = 1}) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: child,
);
void main() {
  for (final kind in [
    NotificationContext.requirement,
    NotificationContext.task,
  ]) {
    testWidgets(
      'duplicate $kind notification opens authorized current detail, no acknowledgement or decision, logout clears it',
      (t) async {
        await initializeDateFormatting('pt_PT');
        final f = WorkFixture();
        await f.start();
        final inbox = InboxController(NotificationRepository(f.auth));
        inbox.activity(false);
        final key = GlobalKey<WorkspaceScreenState>(),
            response = Completer<http.Response>();
        var reads = 0;
        f.workIntercept = (r) async {
          if (r.url.path.endsWith('/notifications/note')) {
            reads++;
            return response.future;
          }
          return null;
        };
        await t.pumpWidget(
          localized(
            WorkspaceScreen(
              key: key,
              repository: null,
              planning: f.c,
              inbox: inbox,
            ),
          ),
        );
        final opening = key.currentState!.openNotification('note');
        await key.currentState!.openNotification('note');
        await t.pump();
        expect(reads, 1);
        response.complete(
          json(
            NotificationView(
              createdAt: DateTime.utc(2026, 9, 10),
              destination: NotificationDestination(
                kind: kind,
                employeeId: 'member',
                resourceId: kind == NotificationContext.task
                    ? 'task'
                    : 'onsite',
                proposalId: null,
              ),
              eventType: kind == NotificationContext.task
                  ? 'task.assigned'
                  : 'onsite.created',
              historical: false,
              id: 'note',
              readAt: null,
            ),
          ),
        );
        await opening;
        await t.pumpAndSettle();
        expect(
          f.c.workId,
          kind == NotificationContext.task ? 'task' : 'onsite',
        );
        expect(f.auth.notificationIntent, isNull);
        expect(f.writes, isEmpty);
        expect(f.c.requirement?.readAt, isNull);
        await f.auth.logout();
        await t.pumpAndSettle();
        expect(f.c.requirement, isNull);
        expect(f.c.task, isNull);
        expect(find.byKey(const Key('work-detail-title')), findsNothing);
        await t.pumpWidget(const SizedBox());
        inbox.dispose();
        f.dispose();
      },
    );
  }
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'work detail, protected editor, validation and back fit 320px at scale $scale',
      (t) async {
        await initializeDateFormatting('pt_PT');
        t.view.physicalSize = const Size(320, 700);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final f = WorkFixture();
        await f.start();
        addTearDown(f.dispose);
        await f.c.openWork(WorkContext.requirement, 'onsite');
        await t.pumpWidget(
          localized(
            Scaffold(body: WorkScreen(f.c, onRequests: () {})),
            scale: scale,
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        await f.c.editWork();
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        await t.scrollUntilVisible(
          find.byKey(const Key('work-reason')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await t.enterText(find.byKey(const Key('work-reason')), '');
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pumpAndSettle();
        await t.scrollUntilVisible(
          find.byKey(const Key('work-save')),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await t.pumpAndSettle();
        await t.ensureVisible(find.byKey(const Key('work-save')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('work-save')));
        await t.pumpAndSettle();
        expect(f.c.review, isNull);
        expect(f.writes, isEmpty);
        expect(t.takeException(), isNull);
        f.c.closeWorkEditor();
        await t.pumpAndSettle();
        await f.c.persist();
        expect(f.c.workId, 'onsite');
        await t.pumpWidget(const SizedBox());
      },
    );
  }
}
