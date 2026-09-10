import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/features/planning/planning_dates.dart';

import 'planning_test.dart' as flow;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android local dates round-trip through actual API/PostgreSQL at both DST transitions',
    (_) async {
      expect(Platform.isAndroid, true);
      const zone = String.fromEnvironment('TEST_DEVICE_ZONE');
      expect(
        ['Europe/Lisbon', 'Europe/Zurich'],
        contains(zone),
        reason: 'Set the emulator timezone before this native test.',
      );
      // Check that the Dart process actually observes the selected device timezone.
      expect(
        DateTime(2027, 1, 1).timeZoneOffset.inHours,
        zone == 'Europe/Zurich' ? 1 : 0,
      );
      expect(
        DateTime(2027, 7, 1).timeZoneOffset.inHours,
        zone == 'Europe/Zurich' ? 2 : 1,
      );
      final c = await flow.client();
      try {
        final employee = (await AccessApi(c).getCurrentMember())!.memberId;
        final today = planningToday('Europe/Zurich');
        // Last Sunday of March/October next year, within the API's 730-day horizon.
        DateTime lastSunday(int month) {
          final last = DateTime(today.year + 1, month + 1, 0);
          return shiftDay(last, -(last.weekday % 7));
        }

        final values = [lastSunday(3), lastSunday(10)];
        final api = PlanningApi(c);
        final calendar = (await api.getCalendar(employee, today, today))!;
        final key = 'android-date-${DateTime.now().microsecondsSinceEpoch}';
        final draft = (await api.createPlanningDraft(
          employee,
          key,
          DraftInput(
            expectedCalendarVersion: calendar.calendarVersion,
            expectedRequestVersion: null,
            parentRevisionId: null,
            note: 'Ensaio de datas Android HO-010 ($zone)',
            days: values
                .map(
                  (d) => DayInput(
                    localDate: d,
                    location: WorkLocation.remotePortugal,
                    availability: Availability.working,
                  ),
                )
                .toList(),
          ),
        ))!;
        final stored = (await api.getPlanningRequest(
          employee,
          draft.contextId,
        ))!;
        expect(
          stored.days.map((d) => dateKey(d.localDate)),
          values.map(dateKey),
        );
        expect(
          stored.state,
          RequestState.draft,
          reason:
              'This date probe never reserves or approves existing work days.',
        );
        for (final date in values) {
          final preview = (await api.previewPlanningDates(
            shiftDay(date, -1),
            shiftDay(date, 1),
            includeWeekends: true,
          ))!;
          expect(preview.days.map((d) => dateKey(d.localDate)), [
            dateKey(shiftDay(date, -1)),
            dateKey(date),
            dateKey(shiftDay(date, 1)),
          ]);
        }
      } finally {
        c.client.close();
      }
    },
  );
}
