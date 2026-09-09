//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DecisionInput {
  /// Returns a new [DecisionInput] instance.
  DecisionInput({
    required this.approve,
    this.days = const [],
    required this.expectedCalendarVersion,
    required this.expectedRequestVersion,
    required this.reason,
  });

  final bool approve;

  final List<SelectedDay> days;

  final int? expectedCalendarVersion;

  final int? expectedRequestVersion;

  final String? reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DecisionInput &&
    other.approve == approve &&
    _deepEquality.equals(other.days, days) &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedRequestVersion == expectedRequestVersion &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (approve.hashCode) +
    (days.hashCode) +
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedRequestVersion == null ? 0 : expectedRequestVersion!.hashCode) +
    (reason == null ? 0 : reason!.hashCode);

  @override
  String toString() => 'DecisionInput[approve=$approve, days=$days, expectedCalendarVersion=$expectedCalendarVersion, expectedRequestVersion=$expectedRequestVersion, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'approve'] = this.approve;
      json[r'days'] = this.days;
    if (this.expectedCalendarVersion != null) {
      json[r'expectedCalendarVersion'] = this.expectedCalendarVersion;
    } else {
      json[r'expectedCalendarVersion'] = null;
    }
    if (this.expectedRequestVersion != null) {
      json[r'expectedRequestVersion'] = this.expectedRequestVersion;
    } else {
      json[r'expectedRequestVersion'] = null;
    }
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
    return json;
  }

  /// Clones this instance of [DecisionInput] and returns a new one where some of the
  /// properties have changed.
  DecisionInput copyWith({
    bool? approve,
    List<SelectedDay>? days,
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedRequestVersion,
    bool expectedRequestVersionSetToNull = false,
    String? reason,
    bool reasonSetToNull = false,
  }) => DecisionInput(
    approve: approve ?? this.approve,
    days: days ?? this.days,
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedRequestVersion: expectedRequestVersionSetToNull ? null : expectedRequestVersion ?? this.expectedRequestVersion,
    reason: reasonSetToNull ? null : reason ?? this.reason,
  );

  /// Returns a new [DecisionInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DecisionInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'approve'), 'Required key "DecisionInput[approve]" is missing from JSON.');
        assert(json[r'approve'] != null, 'Required key "DecisionInput[approve]" has a null value in JSON.');
        assert(json.containsKey(r'days'), 'Required key "DecisionInput[days]" is missing from JSON.');
        assert(json[r'days'] != null, 'Required key "DecisionInput[days]" has a null value in JSON.');
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "DecisionInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedRequestVersion'), 'Required key "DecisionInput[expectedRequestVersion]" is missing from JSON.');
        assert(json.containsKey(r'reason'), 'Required key "DecisionInput[reason]" is missing from JSON.');
        return true;
      }());

      return DecisionInput(
        approve: mapValueOfType<bool>(json, r'approve')!,
        days: SelectedDay.listFromJson(json[r'days']),
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedRequestVersion: mapValueOfType<int>(json, r'expectedRequestVersion'),
        reason: mapValueOfType<String>(json, r'reason'),
      );
    }
    return null;
  }

  static List<DecisionInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DecisionInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DecisionInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DecisionInput> mapFromJson(dynamic json) {
    final map = <String, DecisionInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DecisionInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DecisionInput-objects as value to a dart map
  static Map<String, List<DecisionInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DecisionInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DecisionInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'approve',
    'days',
    'expectedCalendarVersion',
    'expectedRequestVersion',
    'reason',
  };
}
