import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_repository.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_screen.dart';
import 'package:homeoffice_mobile/l10n/generated/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'planning_fixture.dart';

void main() {
  for (final disposeFirst in [false, true]) {
    testWidgets(
      'connection failure is handled when Settings is absent; disposed=$disposeFirst',
      (tester) async {
        await initializeDateFormatting('pt_PT');
        final planning = PlanningFixture();
        await planning.start();
        addTearDown(planning.dispose);
        final pending = Completer<http.Response>();
        var calls = 0;
        final client = ApiClient(basePath: 'http://localhost');
        client.client.close();
        client.client = MockClient((request) {
          calls++;
          if (calls == 1) return pending.future;
          return Future.value(
            http.Response(
              jsonEncode({
                'productName': 'HomeOfficeReservation',
                'apiVersion': 'v1',
                'serverTimeUtc': '2026-09-11T00:00:00Z',
                'planningTimeZones': ['Europe/Lisbon', 'Europe/Zurich'],
              }),
              200,
              headers: {'content-type': 'application/json'},
            ),
          );
        });
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('pt'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WorkspaceScreen(
              repository: WorkspaceRepository(WorkspaceApi(client)),
              planning: planning.c,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('connection-state')), findsNothing);
        if (disposeFirst) {
          await tester.pumpWidget(const SizedBox.shrink());
        }
        pending.completeError(
          http.ClientException(
            'simulated connection closed during navigation/logout',
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (!disposeFirst) {
          await tester.tap(find.text('Definições'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.text('Tentar novamente'), 250);
          expect(find.text('Serviço ligado'), findsNothing);
          await tester.tap(find.text('Tentar novamente'));
          await tester.pumpAndSettle();
          expect(find.text('Serviço ligado'), findsOneWidget);
          expect(calls, 2);
          expect(planning.auth.member, isNotNull);
          expect(planning.c.calendar, isNotNull);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 8));
      },
    );
  }
}
