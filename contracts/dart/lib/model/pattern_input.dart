//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PatternInput {
  /// Returns a new [PatternInput] instance.
  PatternInput({
    required this.effectiveFrom,
    required this.expectedCalendarVersion,
    this.locations = const [],
  });

  final DateTime effectiveFrom;

  final int? expectedCalendarVersion;

  final List<WorkLocation> locations;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PatternInput &&
    other.effectiveFrom == effectiveFrom &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    _deepEquality.equals(other.locations, locations);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (effectiveFrom.hashCode) +
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (locations.hashCode);

  @override
  String toString() => 'PatternInput[effectiveFrom=$effectiveFrom, expectedCalendarVersion=$expectedCalendarVersion, locations=$locations]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'effectiveFrom'] = _dateFormatter.format(this.effectiveFrom);
    if (this.expectedCalendarVersion != null) {
      json[r'expectedCalendarVersion'] = this.expectedCalendarVersion;
    } else {
      json[r'expectedCalendarVersion'] = null;
    }
      json[r'locations'] = this.locations;
    return json;
  }

  /// Clones this instance of [PatternInput] and returns a new one where some of the
  /// properties have changed.
  PatternInput copyWith({
    DateTime? effectiveFrom,
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    List<WorkLocation>? locations,
  }) => PatternInput(
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    locations: locations ?? this.locations,
  );

  /// Returns a new [PatternInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PatternInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'effectiveFrom'), 'Required key "PatternInput[effectiveFrom]" is missing from JSON.');
        assert(json[r'effectiveFrom'] != null, 'Required key "PatternInput[effectiveFrom]" has a null value in JSON.');
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "PatternInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'locations'), 'Required key "PatternInput[locations]" is missing from JSON.');
        assert(json[r'locations'] != null, 'Required key "PatternInput[locations]" has a null value in JSON.');
        return true;
      }());

      return PatternInput(
        effectiveFrom: mapDateTime(json, r'effectiveFrom', r'')!,
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        locations: WorkLocation.listFromJson(json[r'locations']),
      );
    }
    return null;
  }

  static List<PatternInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PatternInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PatternInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PatternInput> mapFromJson(dynamic json) {
    final map = <String, PatternInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PatternInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PatternInput-objects as value to a dart map
  static Map<String, List<PatternInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PatternInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PatternInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'effectiveFrom',
    'expectedCalendarVersion',
    'locations',
  };
}
