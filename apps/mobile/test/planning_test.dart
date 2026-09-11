import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:homeoffice_api/api.dart';
import 'package:homeoffice_mobile/features/planning/planning_controller.dart';
import 'package:homeoffice_mobile/features/planning/planning_dates.dart';
import 'package:homeoffice_mobile/features/planning/planning_repository.dart';
import 'package:http/http.dart' as http;

import 'auth_test.dart' show json;
import 'planning_fixture.dart';

void main() {
  test('explicit 401 between preflight and mutation renews and replays the exact command once', () async {
    final f = PlanningFixture();
    await f.start();
    addTearDown(f.dispose);
    var expired = false;
    f.intercept = (r) async {
      if (r.method == 'GET' && r.url.path.endsWith('/me') && expired) {
        expired = false;
        return json({}, 401);
      }
      if (r.method != 'GET' && f.writes.length == 1) {
        expired = true;
        return json({}, 401);
      }
      return null;
    };
    expect(await f.c.run(f.draft()), true);
    expect(
      expired,
      false,
      reason: 'The profile read encountered expiry and renewed before replay.',
    );
    expect(f.writes, hasLength(2));
    expect(f.writes.last.body, f.writes.first.body);
    expect(
      f.writes.last.headers['Idempotency-Key'],
      f.writes.first.headers['Idempotency-Key'],
    );
    expect(f.c.failure, PlanningFailure.none);
    expect(f.c.journal, isNull);
  });

  test(
    'persistent mutation 401 stops after one replay and 403 is never retried',
    () async {
      for (final status in [401, 403]) {
        final f = PlanningFixture();
        await f.start();
        addTearDown(f.dispose);
        f.intercept = (r) async => r.method == 'GET' ? null : json({}, status);
        expect(await f.c.run(f.draft()), false);
        expect(f.writes, hasLength(status == 401 ? 2 : 1));
        expect(f.c.failure, PlanningFailure.forbidden);
        expect(f.c.journal, isNull);
      }
    },
  );

  test('mutation 401 cannot replay for a different actor', () async {
    final f = PlanningFixture();
    await f.start();
    addTearDown(f.dispose);
    f.intercept = (r) async {
      if (r.method != 'GET') {
        f.actor = 'different-member';
        return json({}, 401);
      }
      return null;
    };
    expect(await f.c.run(f.draft()), false);
    expect(f.writes, hasLength(1));
    expect(f.c.failure, PlanningFailure.forbidden);
  });

  test('uncertain write persists exact generated body and key across restart; recovery has one effect', () async {
    final f = PlanningFixture();
    await f.start();
    addTearDown(f.dispose);
    var effects = 0;
    final accepted = <String>{};
    f.intercept = (r) async {
      if (r.method == 'GET') return null;
      if (accepted.add(r.headers['Idempotency-Key']!)) {
        effects++;
        throw TimeoutException('simulated lost response after server commit');
      }
      return null;
    };
    f.c.newEditor();
    f.c.editor!.note = 'Preserved private input';
    f.c.inputChanged();
    final command = f.draft();
    expect(await f.c.run(command), false);
    expect(f.c.failure, PlanningFailure.uncertain);
    expect(f.c.canWrite, false);
    expect(f.writes, hasLength(1));
    expect(f.saved['journal']['body'], command.body);
    f.c.dispose();
    f.c = PlanningController(PlanningRepository(f.auth), f.store);
    await f.c.initialize();
    expect(
      f.writes,
      hasLength(1),
      reason: 'Restoring does not silently retry a write',
    );
    expect(await f.c.recover(), true);
    expect(effects, 1);
    expect(f.writes, hasLength(2));
    expect(f.writes.last.body, f.writes.first.body);
    expect(
      f.writes.last.headers['Idempotency-Key'],
      f.writes.first.headers['Idempotency-Key'],
    );
    expect(f.c.journal, isNull);
    expect(f.draft(note: 'Changed intent').key, isNot(command.key));
  });

  test('failed secure journal prevents HTTP; simultaneous taps send once without optimistic state', () async {
    final f = PlanningFixture();
    await f.start();
    addTearDown(f.dispose);
    f.store.fail = true;
    expect(await f.c.run(f.draft()), false);
    expect(f.writes, isEmpty);
    expect(f.c.failure, PlanningFailure.storage);
    f.store.fail = false;
    final sent = Completer<void>(), response = Completer<http.Response>();
    f.intercept = (r) async {
      if (r.method == 'GET') return null;
      sent.complete();
      return response.future;
    };
    final command = f.draft(), pending = f.c.run(f.draft());
    await sent.future;
    expect(f.c.lastReceipt, isNull);
    expect(await f.c.run(command), false);
    expect(f.writes, hasLength(1));
    response.complete(
      json(
        MutationReceipt(
          contextId: 'request',
          version: 2,
          calendarVersion: 2,
          eventId: 'event',
        ),
      ),
    );
    expect(await pending, true);
  });

  test('stale version reloads, preserves input, requires review and creates a new intent', () async {
    final f = PlanningFixture();
    await f.start();
    addTearDown(f.dispose);
    f.c.newEditor();
    f.c.editor!.note = 'Keep this reason';
    f.c.inputChanged();
    final old = f.draft();
    f.intercept = (r) async {
      if (r.method == 'GET') return null;
      f.version = 2;
      return json({'code': 'calendar_version_stale'}, 412);
    };
    expect(await f.c.run(old), false);
    expect(f.c.calendar!.calendarVersion, 2);
    expect(f.c.editor!.note, 'Keep this reason');
    expect(f.c.needsReview, true);
    expect(await f.c.run(f.draft()), false);
    expect(f.writes, hasLength(1));
    f.c.reviewed();
    final fresh = f.draft();
    expect(fresh.key, isNot(old.key));
    expect(jsonDecode(fresh.body)['expectedCalendarVersion'], 2);
  });

  test('recoverable read failure retains labelled cache and input, then refresh unlocks', () async {
    final f = PlanningFixture();
    await f.start();
    addTearDown(f.dispose);
    f.c.newEditor();
    f.c.editor!.note = 'Keep offline input';
    f.c.inputChanged();
    f.offline = true;
    await f.c.refresh();
    expect(f.c.dataStale, true);
    expect(f.c.canWrite, false);
    expect(f.c.calendar, isNotNull);
    expect(f.c.editor!.note, 'Keep offline input');
    expect(f.writes, isEmpty);
    f.offline = false;
    await f.c.refresh();
    expect(f.c.canWrite, true);
  });

  test('late month response cannot overwrite a newer query', () async {
    final f = PlanningFixture();
    await f.start();
    addTearDown(f.dispose);
    final started = Completer<void>(), delayed = Completer<http.Response>();
    var first = true;
    f.intercept = (r) async {
      if (r.url.path.endsWith('/calendar') && first) {
        first = false;
        started.complete();
        return delayed.future;
      }
      return null;
    };
    final old = f.c.goMonth(DateTime(2027, 3));
    await started.future;
    await f.c.goMonth(DateTime(2027, 10));
    final current = f.c.calendar;
    delayed.complete(
      json(
        CalendarView(
          calendarVersion: 99,
          employeeId: 'member',
          from: DateTime(2027, 3),
          to: DateTime(2027, 4),
          planningTimeZone: 'Europe/Lisbon',
        ),
      ),
    );
    await old;
    expect(f.c.calendar, same(current));
  });

  test(
    'logout erases private drafts and prevents late data from returning',
    () async {
      final f = PlanningFixture();
      await f.start();
      addTearDown(f.dispose);
      f.c.newEditor();
      f.c.editor!.note = 'Private';
      f.c.inputChanged();
      await f.c.persist();
      final started = Completer<void>(), response = Completer<http.Response>();
      f.intercept = (r) async {
        if (r.url.path.endsWith('/requests/request')) {
          started.complete();
          return response.future;
        }
        return null;
      };
      final pending = f.c.openRequest('request');
      await started.future;
      await f.auth.logout();
      expect(f.store.value, isNull);
      expect(f.c.editor, isNull);
      expect(f.c.calendar, isNull);
      response.complete(json(f.request));
      expect(await pending, false);
      expect(f.c.detail, isNull);
    },
  );

  test(
    'protected expired-session draft only restores for the same account',
    () async {
      final f = PlanningFixture();
      await f.start();
      addTearDown(f.dispose);
      f.c.newEditor();
      f.c.editor!.note = 'Private';
      f.c.inputChanged();
      await f.c.clearSession(false);
      f.c.dispose();
      f.c = PlanningController(PlanningRepository(f.auth), f.store);
      await f.c.initialize();
      f.c.newEditor();
      expect(f.c.editor!.note, 'Private');
      await f.c.clearSession(false);
      f.c.dispose();
      f.actor = 'other';
      await f.auth.login('other@test.example', 'simulated');
      f.c = PlanningController(PlanningRepository(f.auth), f.store);
      await f.c.initialize();
      f.c.newEditor();
      expect(f.c.editor!.note, isEmpty);
      expect(f.store.value, isNull);
    },
  );

  test('date-only calendar and generated payload survive Lisbon/Zurich DST boundaries', () {
    for (final value in [
      '2027-03-27',
      '2027-03-28',
      '2027-03-29',
      '2027-10-30',
      '2027-10-31',
      '2027-11-01',
    ]) {
      final date = DateTime.parse(value);
      final dto = DayInput(
        localDate: date,
        availability: Availability.working,
        location: WorkLocation.remotePortugal,
      );
      expect(jsonDecode(jsonEncode(dto))['localDate'], value);
      expect(
        dateKey(DayInput.fromJson(jsonDecode(jsonEncode(dto)))!.localDate),
        value,
      );
      expect(shiftDay(shiftDay(date, 1), -1), date);
      expect(monthGrid(date), contains(date));
    }
    final instant = DateTime.utc(2027, 3, 28, 22, 30);
    expect(
      dateKey(planningToday('Europe/Lisbon', instant: instant)),
      '2027-03-28',
    );
    expect(
      dateKey(planningToday('Europe/Zurich', instant: instant)),
      '2027-03-29',
    );
  });
}
