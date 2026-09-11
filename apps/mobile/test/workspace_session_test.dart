import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/config/api_settings.dart';
import 'package:homeoffice_mobile/features/auth/auth_controller.dart';
import 'package:homeoffice_mobile/features/planning/planning_store.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';
import 'package:homeoffice_mobile/main.dart';
import 'package:homeoffice_mobile/theme/appearance.dart';
import 'package:homeoffice_mobile/theme/components.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'auth_test.dart' show MemoryStore, json, profile;
import 'work_fixture.dart';

class SessionFixture extends WorkFixture {
  int checks = 0;
  bool forbidden = false;
  Map<String, Object> get owner => {
    ...profile,
    'displayName': 'Titular sintético',
    'isAccountAdministrator': true,
  };
  SessionFixture() {
    workIntercept = (request) async {
      final path = request.url.path;
      if (path.endsWith('/me')) {
        checks++;
        return forbidden
            ? json({}, 403)
            : json(
                actor == 'member'
                    ? owner
                    : {
                        ...profile,
                        'memberId': actor,
                        'displayName': 'Chefia sintética',
                        'isEmployee': false,
                        'isManager': true,
                      },
              );
      }
      if (path.endsWith('/members')) {
        return json({
          'members': [owner],
        });
      }
      if (path.endsWith('/management-access')) return json(owner);
      if (path.endsWith('/unread-count')) return json({'unreadCount': 6});
      if (path.endsWith('/notifications')) {
        return json(
          NotificationPage(
            unreadCount: 6,
            items: List.generate(
              6,
              (i) => NotificationView(
                createdAt: DateTime.utc(2026, 9, 11),
                destination: null,
                eventType: 'task.assigned',
                historical: false,
                id: 'note-$i',
                readAt: null,
              ),
            ),
            nextOffset: null,
          ),
        );
      }
      return null;
    };
  }
}

Future<void> activate(
  WidgetTester t,
  SessionFixture f, {
  Brightness brightness = Brightness.light,
}) async {
  await initializeDateFormatting('pt_PT');
  FlutterSecureStorage.setMockInitialValues({});
  await f.auth.login('employee@test.example', 'simulated-password');
  final appearance = AppearanceController();
  await appearance.select(
    brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
  );
  addTearDown(appearance.dispose);
  await t.pumpWidget(
    HomeOfficeApp(repository: null, auth: f.auth, appearance: appearance),
  );
  await t.pumpAndSettle();
  expect(find.byType(WorkspaceScreen), findsOneWidget);
}

Future<void> settings(WidgetTester t) async {
  await t.tap(find.byIcon(Icons.settings_outlined));
  await t.pumpAndSettle();
  await t.ensureVisible(find.text('Conta e sessão'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'scrolling headers across themes and text sizes preserve session checking, cleanup and account switching',
    (t) async {
      // One continuous app lifetime also verifies that preferences and tab scroll
      // positions do not leak the previous identity during an account switch.
      final f = SessionFixture();
      await activate(t, f);
      addTearDown(t.view.reset);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      for (final brightness in Brightness.values) {
        for (final scale in [1.0, 2.0]) {
          t.view.physicalSize = const Size(320, 480);
          t.view.devicePixelRatio = 1;
          t.view.padding = const FakeViewPadding(top: 24, bottom: 16);
          t.platformDispatcher.textScaleFactorTestValue = scale;
          await AppearanceScope.of(
            t.element(find.byType(WorkspaceScreen)),
          )!.select(
            brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          );
          for (final icon in [
            Icons.calendar_month_outlined,
            Icons.north_east,
            Icons.task_alt,
            Icons.notifications_outlined,
            Icons.settings_outlined,
          ]) {
            await t.tap(find.byIcon(icon));
            await t.pumpAndSettle();
            t
                .state<ScrollableState>(find.byType(Scrollable).first)
                .position
                .jumpTo(0);
            await t.pumpAndSettle();
            final heading = find.byType(SectionHeading);
            expect(heading.hitTestable(), findsOneWidget);
            expect(t.getTopLeft(heading).dy, greaterThanOrEqualTo(24));
            expect(find.byType(AppBar), findsNothing);
            expect(find.byType(SliverAppBar), findsNothing);
            expect(
              find.text('Conta e sessão'),
              icon == Icons.settings_outlined ? findsOneWidget : findsNothing,
            );
            expect(
              find.byKey(const Key('authenticated-member-name')),
              icon == Icons.settings_outlined ? findsOneWidget : findsNothing,
            );
            await t.drag(find.byType(Scrollable).first, const Offset(0, -900));
            await t.pumpAndSettle();
            expect(heading.hitTestable(), findsNothing);
            expect(find.byType(NavigationBar).hitTestable(), findsOneWidget);
            expect(t.takeException(), isNull);
          }
        }
      }

      t.view.reset();
      t.platformDispatcher.clearTextScaleFactorTestValue();
      await t.pumpAndSettle();
      final c = t
          .widget<WorkspaceScreen>(find.byType(WorkspaceScreen))
          .planning!;
      c.newEditor();
      c.editor!.note = 'Private synthetic draft';
      await c.persist();
      expect(await SecurePlanningStore(ApiSettings.baseUrl).read(), isNotNull);
      f.auth.rememberNotification('private-intent');
      await settings(t);
      expect(find.text('Titular sintético'), findsOneWidget);
      expect(find.text('employee@test.example'), findsOneWidget);
      final checks = f.checks;
      await t.ensureVisible(find.text('Verificar sessão'));
      await t.pumpAndSettle();
      await t.tap(find.text('Verificar sessão'));
      await t.pumpAndSettle();
      expect(f.checks, greaterThan(checks));
      expect(f.auth.member!.memberId, 'member');
      expect(c.editor!.note, 'Private synthetic draft');
      var cleaned = false;
      final cleanup = f.auth.onSigningOut!;
      f.auth.onSigningOut = () async {
        await cleanup();
        cleaned = true;
      };
      await t.ensureVisible(find.text('Terminar sessão'));
      await t.pumpAndSettle();
      await t.tap(find.text('Terminar sessão'));
      await t.pumpAndSettle();
      for (var i = 0; i < 60 && f.auth.member != null; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      expect(
        cleaned,
        isTrue,
        reason:
            'state=${f.auth.message.name}; signedIn=${f.auth.member != null}; planningActive=${c.active}',
      );
      expect(c.active, isFalse);
      expect(c.editor, isNull);
      expect(await SecurePlanningStore(ApiSettings.baseUrl).read(), isNull);
      expect((f.auth.store as MemoryStore).value, isNull);
      expect(
        f.auth.client.defaultHeaderMap.containsKey('Authorization'),
        isFalse,
      );
      expect(f.auth.notificationIntent, isNull);
      expect(find.byType(WorkspaceScreen), findsNothing);
      f.actor = 'manager';
      await t.enterText(find.byKey(const Key('email')), 'manager@test.example');
      await t.enterText(
        find.byKey(const Key('password')),
        'simulated-password',
      );
      await t.tap(find.byKey(const Key('submit')));
      await t.pumpAndSettle();
      final next = t
          .widget<WorkspaceScreen>(find.byType(WorkspaceScreen))
          .planning!;
      expect(next.actor, 'manager');
      expect(next.editor, isNull);
      expect(next.employeeId, 'member');
      expect(find.byKey(const ValueKey('employee-member')), findsOneWidget);
      expect(find.text('Titular sintético'), findsOneWidget);
      expect(find.text('Chefia sintética'), findsNothing);
      await settings(t);
      expect(find.text('Chefia sintética'), findsOneWidget);
      expect(find.text('Titular sintético'), findsNothing);
      await t.tap(find.byIcon(Icons.calendar_month_outlined));
      await t.pumpAndSettle();
      expect(find.text('Verificar sessão'), findsNothing);
      final resumeChecks = f.checks;
      f.forbidden = true;
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pumpAndSettle();
      expect(f.checks, greaterThan(resumeChecks));
      expect(f.auth.member, isNull);
      expect(f.auth.message, AuthMessage.forbidden);
      expect((f.auth.store as MemoryStore).value, isNull);
      expect(find.byType(WorkspaceScreen), findsNothing);
      expect(
        find.text(
          'Acesso não autorizado. Contacte o administrador da organização.',
        ),
        findsOneWidget,
      );
      await t.pumpWidget(const SizedBox.shrink());
      await t.pump(const Duration(seconds: 16));
    },
  );
}
