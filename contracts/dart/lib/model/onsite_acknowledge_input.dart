//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OnsiteAcknowledgeInput {
  /// Returns a new [OnsiteAcknowledgeInput] instance.
  OnsiteAcknowledgeInput({
    required this.expectedCalendarVersion,
    required this.expectedVersion,
    required this.revision,
  });

  final int? expectedCalendarVersion;

  final int? expectedVersion;

  final int revision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OnsiteAcknowledgeInput &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedVersion == expectedVersion &&
    other.revision == revision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedVersion == null ? 0 : expectedVersion!.hashCode) +
    (revision.hashCode);

  @override
  String toString() => 'OnsiteAcknowledgeInput[expectedCalendarVersion=$expectedCalendarVersion, expectedVersion=$expectedVersion, revision=$revision]';

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
      json[r'revision'] = this.revision;
    return json;
  }

  /// Clones this instance of [OnsiteAcknowledgeInput] and returns a new one where some of the
  /// properties have changed.
  OnsiteAcknowledgeInput copyWith({
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedVersion,
    bool expectedVersionSetToNull = false,
    int? revision,
  }) => OnsiteAcknowledgeInput(
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedVersion: expectedVersionSetToNull ? null : expectedVersion ?? this.expectedVersion,
    revision: revision ?? this.revision,
  );

  /// Returns a new [OnsiteAcknowledgeInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OnsiteAcknowledgeInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "OnsiteAcknowledgeInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedVersion'), 'Required key "OnsiteAcknowledgeInput[expectedVersion]" is missing from JSON.');
        assert(json.containsKey(r'revision'), 'Required key "OnsiteAcknowledgeInput[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "OnsiteAcknowledgeInput[revision]" has a null value in JSON.');
        return true;
      }());

      return OnsiteAcknowledgeInput(
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion'),
        revision: mapValueOfType<int>(json, r'revision')!,
      );
    }
    return null;
  }

  static List<OnsiteAcknowledgeInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OnsiteAcknowledgeInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OnsiteAcknowledgeInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OnsiteAcknowledgeInput> mapFromJson(dynamic json) {
    final map = <String, OnsiteAcknowledgeInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OnsiteAcknowledgeInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OnsiteAcknowledgeInput-objects as value to a dart map
  static Map<String, List<OnsiteAcknowledgeInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OnsiteAcknowledgeInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OnsiteAcknowledgeInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedCalendarVersion',
    'expectedVersion',
    'revision',
  };
}
