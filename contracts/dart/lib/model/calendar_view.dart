//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CalendarView {
  /// Returns a new [CalendarView] instance.
  CalendarView({
    required this.calendarVersion,
    this.effectiveDays = const [],
    required this.employeeId,
    required this.from,
    this.pendingDays = const [],
    required this.planningTimeZone,
    required this.to,
  });

  final int calendarVersion;

  final List<EffectiveDay> effectiveDays;

  final String employeeId;

  final DateTime from;

  final List<PendingDay> pendingDays;

  final String planningTimeZone;

  final DateTime to;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CalendarView &&
    other.calendarVersion == calendarVersion &&
    _deepEquality.equals(other.effectiveDays, effectiveDays) &&
    other.employeeId == employeeId &&
    other.from == from &&
    _deepEquality.equals(other.pendingDays, pendingDays) &&
    other.planningTimeZone == planningTimeZone &&
    other.to == to;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (calendarVersion.hashCode) +
    (effectiveDays.hashCode) +
    (employeeId.hashCode) +
    (from.hashCode) +
    (pendingDays.hashCode) +
    (planningTimeZone.hashCode) +
    (to.hashCode);

  @override
  String toString() => 'CalendarView[calendarVersion=$calendarVersion, effectiveDays=$effectiveDays, employeeId=$employeeId, from=$from, pendingDays=$pendingDays, planningTimeZone=$planningTimeZone, to=$to]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'calendarVersion'] = this.calendarVersion;
      json[r'effectiveDays'] = this.effectiveDays;
      json[r'employeeId'] = this.employeeId;
      json[r'from'] = _dateFormatter.format(this.from);
      json[r'pendingDays'] = this.pendingDays;
      json[r'planningTimeZone'] = this.planningTimeZone;
      json[r'to'] = _dateFormatter.format(this.to);
    return json;
  }

  /// Clones this instance of [CalendarView] and returns a new one where some of the
  /// properties have changed.
  CalendarView copyWith({
    int? calendarVersion,
    List<EffectiveDay>? effectiveDays,
    String? employeeId,
    DateTime? from,
    List<PendingDay>? pendingDays,
    String? planningTimeZone,
    DateTime? to,
  }) => CalendarView(
    calendarVersion: calendarVersion ?? this.calendarVersion,
    effectiveDays: effectiveDays ?? this.effectiveDays,
    employeeId: employeeId ?? this.employeeId,
    from: from ?? this.from,
    pendingDays: pendingDays ?? this.pendingDays,
    planningTimeZone: planningTimeZone ?? this.planningTimeZone,
    to: to ?? this.to,
  );

  /// Returns a new [CalendarView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CalendarView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'calendarVersion'), 'Required key "CalendarView[calendarVersion]" is missing from JSON.');
        assert(json[r'calendarVersion'] != null, 'Required key "CalendarView[calendarVersion]" has a null value in JSON.');
        assert(json.containsKey(r'effectiveDays'), 'Required key "CalendarView[effectiveDays]" is missing from JSON.');
        assert(json[r'effectiveDays'] != null, 'Required key "CalendarView[effectiveDays]" has a null value in JSON.');
        assert(json.containsKey(r'employeeId'), 'Required key "CalendarView[employeeId]" is missing from JSON.');
        assert(json[r'employeeId'] != null, 'Required key "CalendarView[employeeId]" has a null value in JSON.');
        assert(json.containsKey(r'from'), 'Required key "CalendarView[from]" is missing from JSON.');
        assert(json[r'from'] != null, 'Required key "CalendarView[from]" has a null value in JSON.');
        assert(json.containsKey(r'pendingDays'), 'Required key "CalendarView[pendingDays]" is missing from JSON.');
        assert(json[r'pendingDays'] != null, 'Required key "CalendarView[pendingDays]" has a null value in JSON.');
        assert(json.containsKey(r'planningTimeZone'), 'Required key "CalendarView[planningTimeZone]" is missing from JSON.');
        assert(json[r'planningTimeZone'] != null, 'Required key "CalendarView[planningTimeZone]" has a null value in JSON.');
        assert(json.containsKey(r'to'), 'Required key "CalendarView[to]" is missing from JSON.');
        assert(json[r'to'] != null, 'Required key "CalendarView[to]" has a null value in JSON.');
        return true;
      }());

      return CalendarView(
        calendarVersion: mapValueOfType<int>(json, r'calendarVersion')!,
        effectiveDays: EffectiveDay.listFromJson(json[r'effectiveDays']),
        employeeId: mapValueOfType<String>(json, r'employeeId')!,
        from: mapDateTime(json, r'from', r'')!,
        pendingDays: PendingDay.listFromJson(json[r'pendingDays']),
        planningTimeZone: mapValueOfType<String>(json, r'planningTimeZone')!,
        to: mapDateTime(json, r'to', r'')!,
      );
    }
    return null;
  }

  static List<CalendarView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CalendarView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CalendarView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CalendarView> mapFromJson(dynamic json) {
    final map = <String, CalendarView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CalendarView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CalendarView-objects as value to a dart map
  static Map<String, List<CalendarView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CalendarView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CalendarView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'calendarVersion',
    'effectiveDays',
    'employeeId',
    'from',
    'pendingDays',
    'planningTimeZone',
    'to',
  };
}
