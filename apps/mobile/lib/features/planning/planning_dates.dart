import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as database;
import 'package:timezone/timezone.dart' as tz;

// Planning values use calendar components, never an instant at UTC midnight.
DateTime dayOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
DateTime shiftDay(DateTime value, int days) =>
    DateTime(value.year, value.month, value.day + days);
String dateKey(DateTime value) => DateFormat('yyyy-MM-dd').format(value);
String dayLabel(DateTime value) =>
    DateFormat('EEE, d MMM yyyy', 'pt_PT').format(value);
bool sameDay(DateTime a, DateTime b) => dateKey(a) == dateKey(b);

bool _zonesReady = false;
DateTime planningToday(String zone, {DateTime? instant}) {
  if (!_zonesReady) {
    database.initializeTimeZones();
    _zonesReady = true;
  }
  final value = tz.TZDateTime.from(
    instant ?? DateTime.now(),
    tz.getLocation(zone),
  );
  return DateTime(value.year, value.month, value.day);
}

List<DateTime> monthGrid(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final start = shiftDay(first, 1 - first.weekday);
  return List.generate(42, (index) => shiftDay(start, index));
}
