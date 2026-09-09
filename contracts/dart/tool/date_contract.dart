// Exercises generated serializers and HTTP query construction with a simulated transport.
// No duplicated DTO, credentials, calendar data or server integration claims.
import 'dart:convert';

import 'package:homeoffice_api/api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Future<void> main() async {
  for (final iso in ['2026-10-25', '2027-03-28']) {
    final date = DateTime.parse(iso);
    final input = DayInput(
      availability: Availability.working,
      localDate: date,
      location: WorkLocation.remotePortugal,
    );
    if (input.toJson()['localDate'] != iso ||
        DayInput.fromJson(jsonDecode(jsonEncode(input)))!.localDate.day !=
            date.day) {
      throw StateError('Date-only body changed the selected day');
    }
    var requested = false;
    final client = ApiClient(basePath: 'https://example.invalid');
    client.client = MockClient((request) async {
      requested = true;
      if (request.url.queryParameters['from'] != iso ||
          request.url.queryParameters['to'] != iso) {
        throw StateError('Date-only query changed the selected day');
      }
      return http.Response(
        '{"days":[{"localDate":"$iso","isWeekend":true}]}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final preview = await PlanningApi(client).previewPlanningDates(date, date);
    if (!requested || preview?.days.single.localDate.day != date.day) {
      throw StateError('Date-only response changed the selected day');
    }
    client.client.close();
  }
  print(
    'Generated Dart date-only body/query/response checks passed (simulated HTTP).',
  );
}
