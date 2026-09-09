//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WorkVersionInput {
  /// Returns a new [WorkVersionInput] instance.
  WorkVersionInput({
    required this.expectedCalendarVersion,
    required this.expectedVersion,
  });

  final int? expectedCalendarVersion;

  final int? expectedVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkVersionInput &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedVersion == expectedVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedVersion == null ? 0 : expectedVersion!.hashCode);

  @override
  String toString() => 'WorkVersionInput[expectedCalendarVersion=$expectedCalendarVersion, expectedVersion=$expectedVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.expectedCalendarVersion != null) {
      json[r'expectedCalendarVersion'] = this.expectedCalendarVersion;
    } else {
      json[r'expectedCalendarVersion'] = null;
    }
    if (this.expectedVersion != null) {
      json[r'expectedVersion'] = this.expectedVersion;
    } else {
      json[r'expectedVersion'] = null;
    }
    return json;
  }

  /// Clones this instance of [WorkVersionInput] and returns a new one where some of the
  /// properties have changed.
  WorkVersionInput copyWith({
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedVersion,
    bool expectedVersionSetToNull = false,
  }) => WorkVersionInput(
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedVersion: expectedVersionSetToNull ? null : expectedVersion ?? this.expectedVersion,
  );

  /// Returns a new [WorkVersionInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkVersionInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "WorkVersionInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedVersion'), 'Required key "WorkVersionInput[expectedVersion]" is missing from JSON.');
        return true;
      }());

      return WorkVersionInput(
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion'),
      );
    }
    return null;
  }

  static List<WorkVersionInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkVersionInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkVersionInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkVersionInput> mapFromJson(dynamic json) {
    final map = <String, WorkVersionInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkVersionInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkVersionInput-objects as value to a dart map
  static Map<String, List<WorkVersionInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkVersionInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkVersionInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedCalendarVersion',
    'expectedVersion',
  };
}
