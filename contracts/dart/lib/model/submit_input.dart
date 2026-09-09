//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SubmitInput {
  /// Returns a new [SubmitInput] instance.
  SubmitInput({
    required this.expectedCalendarVersion,
    required this.expectedRequestVersion,
  });

  final int? expectedCalendarVersion;

  final int? expectedRequestVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SubmitInput &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedRequestVersion == expectedRequestVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedRequestVersion == null ? 0 : expectedRequestVersion!.hashCode);

  @override
  String toString() => 'SubmitInput[expectedCalendarVersion=$expectedCalendarVersion, expectedRequestVersion=$expectedRequestVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
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

  /// Clones this instance of [SubmitInput] and returns a new one where some of the
  /// properties have changed.
  SubmitInput copyWith({
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedRequestVersion,
    bool expectedRequestVersionSetToNull = false,
  }) => SubmitInput(
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedRequestVersion: expectedRequestVersionSetToNull ? null : expectedRequestVersion ?? this.expectedRequestVersion,
  );

  /// Returns a new [SubmitInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SubmitInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "SubmitInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedRequestVersion'), 'Required key "SubmitInput[expectedRequestVersion]" is missing from JSON.');
        return true;
      }());

      return SubmitInput(
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedRequestVersion: mapValueOfType<int>(json, r'expectedRequestVersion'),
      );
    }
    return null;
  }

  static List<SubmitInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SubmitInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SubmitInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SubmitInput> mapFromJson(dynamic json) {
    final map = <String, SubmitInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SubmitInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SubmitInput-objects as value to a dart map
  static Map<String, List<SubmitInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SubmitInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SubmitInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedCalendarVersion',
    'expectedRequestVersion',
  };
}
