//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WithdrawInput {
  /// Returns a new [WithdrawInput] instance.
  WithdrawInput({
    this.days = const [],
    required this.expectedCalendarVersion,
    required this.expectedRequestVersion,
  });

  final List<SelectedDay> days;

  final int? expectedCalendarVersion;

  final int? expectedRequestVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WithdrawInput &&
    _deepEquality.equals(other.days, days) &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedRequestVersion == expectedRequestVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (days.hashCode) +
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedRequestVersion == null ? 0 : expectedRequestVersion!.hashCode);

  @override
  String toString() => 'WithdrawInput[days=$days, expectedCalendarVersion=$expectedCalendarVersion, expectedRequestVersion=$expectedRequestVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
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
    return json;
  }

  /// Clones this instance of [WithdrawInput] and returns a new one where some of the
  /// properties have changed.
  WithdrawInput copyWith({
    List<SelectedDay>? days,
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedRequestVersion,
    bool expectedRequestVersionSetToNull = false,
  }) => WithdrawInput(
    days: days ?? this.days,
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedRequestVersion: expectedRequestVersionSetToNull ? null : expectedRequestVersion ?? this.expectedRequestVersion,
  );

  /// Returns a new [WithdrawInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WithdrawInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'days'), 'Required key "WithdrawInput[days]" is missing from JSON.');
        assert(json[r'days'] != null, 'Required key "WithdrawInput[days]" has a null value in JSON.');
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "WithdrawInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedRequestVersion'), 'Required key "WithdrawInput[expectedRequestVersion]" is missing from JSON.');
        return true;
      }());

      return WithdrawInput(
        days: SelectedDay.listFromJson(json[r'days']),
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedRequestVersion: mapValueOfType<int>(json, r'expectedRequestVersion'),
      );
    }
    return null;
  }

  static List<WithdrawInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WithdrawInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WithdrawInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WithdrawInput> mapFromJson(dynamic json) {
    final map = <String, WithdrawInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WithdrawInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WithdrawInput-objects as value to a dart map
  static Map<String, List<WithdrawInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WithdrawInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WithdrawInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'days',
    'expectedCalendarVersion',
    'expectedRequestVersion',
  };
}
