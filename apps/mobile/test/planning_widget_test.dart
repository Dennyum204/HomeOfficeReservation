import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/notifications/inbox_controller.dart';
import 'package:homeoffice_mobile/features/notifications/notification_repository.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_mobile/features/planning/planning_screen.dart';
import 'package:homeoffice_mobile/l10n/generated/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'planning_fixture.dart';
import 'auth_test.dart' show json;

import 'package:homeoffice_mobile/theme/app_theme.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'calendar has labeled touch targets and accessible text contrast in $brightness',
      (t) async {
        await initializeDateFormatting('pt_PT');
        t.view.physicalSize = const Size(411, 914);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final semantics = t.ensureSemantics();
        final f = PlanningFixture();
        await f.start();
        addTearDown(f.dispose);
        await t.pumpWidget(
          MaterialApp(
            theme: appTheme(brightness),
            locale: const Locale('pt'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PlanningScreen(
                controller: f.c,
                requests: false,
                onRequests: () {},
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        try {
          await expectLater(t, meetsGuideline(androidTapTargetGuideline));
          await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(t, meetsGuideline(textContrastGuideline));
        } finally {
          semantics.dispose();
        }
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets(
    'returning to a scrolled calendar keeps legend state separate from scroll offset',
    (t) async {
      await initializeDateFormatting('pt_PT');
      final f = PlanningFixture();
      await f.start();
      addTearDown(f.dispose);
      final key = GlobalKey<WorkspaceScreenState>();
      await t.pumpWidget(
        MaterialApp(
          theme: appTheme(Brightness.dark),
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkspaceScreen(key: key, repository: null, planning: f.c),
        ),
      );
      await t.pumpAndSettle();
      await t.drag(find.byType(ListView).first, const Offset(0, -300));
      await t.pumpAndSettle();
      await t.ensureVisible(find.byType(ExpansionTile));
      await t.tap(find.byType(ExpansionTile));
      await t.pumpAndSettle();
      key.currentState!.selectSection(4);
      await t.pumpAndSettle();
      key.currentState!.selectSection(0);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(f.writes, isEmpty);
      await t.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'notification duplicate taps fetch authorized current detail once and retain no push business data',
    (tester) async {
      await initializeDateFormatting('pt_PT');
      final f = PlanningFixture();
      await f.start();
      final inbox = InboxController(NotificationRepository(f.auth));
      inbox.activity(false);
      final key = GlobalKey<WorkspaceScreenState>();
      final pending = Completer<http.Response>();
      var calls = 0;
      f.intercept = (r) async {
        if (r.url.path.endsWith('/notifications/note')) {
          calls++;
          return pending.future;
        }
        return null;
      };
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkspaceScreen(
            key: key,
            repository: null,
            inbox: inbox,
            planning: f.c,
          ),
        ),
      );
      final opening = key.currentState!.openNotification('note');
      await key.currentState!.openNotification('note');
      await tester.pump();
      expect(calls, 1);
      expect(f.c.detail, isNull);
      pending.complete(
        json(
          NotificationView(
            createdAt: DateTime.utc(2026, 9, 10),
            destination: NotificationDestination(
              kind: NotificationContext.request,
              employeeId: 'member',
              resourceId: 'request',
              proposalId: null,
            ),
            eventType: 'planning.decided',
            historical: false,
            id: 'note',
            readAt: null,
          ),
        ),
      );
      await opening;
      await tester.pumpAndSettle();
      expect(f.c.detail!.id, 'request');
      expect(find.text('0 dias aprovados · 0 dias pendentes'), findsOneWidget);
      expect(f.auth.notificationIntent, isNull);
      expect(
        f.writes,
        isEmpty,
        reason: 'Opening performs no decision or read-status mutation',
      );
      await f.auth.logout();
      await tester.pumpAndSettle();
      expect(f.c.detail, isNull);
      expect(find.text('Synthetic input'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      inbox.dispose();
      f.dispose();
    },
  );
  for (final (scale, brightness) in [
    for (final b in Brightness.values)
      for (final s in [1.0, 2.0]) (s, b),
  ]) {
    testWidgets(
      'calendar, editor and frozen review fit 320px at text scale $scale in $brightness',
      (tester) async {
        await initializeDateFormatting('pt_PT');
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final f = PlanningFixture();
        await f.start();
        addTearDown(f.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: appTheme(brightness),
            locale: const Locale('pt'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: PlanningScreen(
                controller: f.c,
                requests: false,
                onRequests: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        f.c.newEditor();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        f.c.reviewCommand(f.draft(), 'Guardar rascunho', [
          '28/03/2027 · Remoto — Portugal',
          'Comentário sintético',
        ]);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.byKey(const Key('planning-confirm')),
          200,
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('planning-confirm')).hitTestable(),
          findsOneWidget,
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(f.c.review, isNull);
        expect(f.c.editor, isNotNull);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(f.c.editor, isNull);
        expect(f.c.hasSavedEditor, true);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
