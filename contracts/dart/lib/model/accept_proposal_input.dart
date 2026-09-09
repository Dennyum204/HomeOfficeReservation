//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AcceptProposalInput {
  /// Returns a new [AcceptProposalInput] instance.
  AcceptProposalInput({
    required this.expectedCalendarVersion,
    required this.expectedProposalRevision,
  });

  final int? expectedCalendarVersion;

  final int expectedProposalRevision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AcceptProposalInput &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedProposalRevision == expectedProposalRevision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedProposalRevision.hashCode);

  @override
  String toString() => 'AcceptProposalInput[expectedCalendarVersion=$expectedCalendarVersion, expectedProposalRevision=$expectedProposalRevision]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.expectedCalendarVersion != null) {
      json[r'expectedCalendarVersion'] = this.expectedCalendarVersion;
    } else {
      json[r'expectedCalendarVersion'] = null;
    }
      json[r'expectedProposalRevision'] = this.expectedProposalRevision;
    return json;
  }

  /// Clones this instance of [AcceptProposalInput] and returns a new one where some of the
  /// properties have changed.
  AcceptProposalInput copyWith({
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedProposalRevision,
  }) => AcceptProposalInput(
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedProposalRevision: expectedProposalRevision ?? this.expectedProposalRevision,
  );

  /// Returns a new [AcceptProposalInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AcceptProposalInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "AcceptProposalInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedProposalRevision'), 'Required key "AcceptProposalInput[expectedProposalRevision]" is missing from JSON.');
        assert(json[r'expectedProposalRevision'] != null, 'Required key "AcceptProposalInput[expectedProposalRevision]" has a null value in JSON.');
        return true;
      }());

      return AcceptProposalInput(
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedProposalRevision: mapValueOfType<int>(json, r'expectedProposalRevision')!,
      );
    }
    return null;
  }

  static List<AcceptProposalInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AcceptProposalInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AcceptProposalInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AcceptProposalInput> mapFromJson(dynamic json) {
    final map = <String, AcceptProposalInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AcceptProposalInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AcceptProposalInput-objects as value to a dart map
  static Map<String, List<AcceptProposalInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AcceptProposalInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AcceptProposalInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedCalendarVersion',
    'expectedProposalRevision',
  };
}
