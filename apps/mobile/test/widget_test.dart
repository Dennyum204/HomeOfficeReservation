import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/workspace/workspace_repository.dart';
import 'package:homeoffice_mobile/main.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets(
    'small screen navigation labels unfinished work and recovers connectivity',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var calls = 0;
      final client = ApiClient(basePath: 'http://localhost');
      client.client.close();
      client.client = MockClient((request) async {
        expect(request.url.path, '/api/v1/workspace');
        calls++;
        if (calls == 1) return http.Response('', 503);
        return http.Response(
          jsonEncode({
            'productName': 'HomeOfficeReservation',
            'apiVersion': 'v1',
            'serverTimeUtc': '2026-09-08T10:00:00Z',
            'planningTimeZones': ['Europe/Lisbon', 'Europe/Zurich'],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      await tester.pumpWidget(
        HomeOfficeApp(repository: WorkspaceRepository(WorkspaceApi(client))),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Tentar novamente'), 250);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(find.text('Serviço ligado'), findsOneWidget);
      expect(calls, 2);
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'A submissão e a aprovação de pedidos ainda não estão disponíveis.',
        ),
        findsOneWidget,
      );
      expect(find.text('Aprovar'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 8));
    },
  );

  testWidgets('invalid configuration remains visibly disconnected', (
    tester,
  ) async {
    await tester.pumpWidget(const HomeOfficeApp(repository: null));
    await tester.pumpAndSettle();
    expect(
      find.text('A ligação ao serviço não está configurada nesta versão.'),
      findsOneWidget,
    );
    expect(find.text('Serviço ligado'), findsNothing);
  });
}
