//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WorkCommentInput {
  /// Returns a new [WorkCommentInput] instance.
  WorkCommentInput({
    required this.expectedCalendarVersion,
    required this.text,
  });

  final int? expectedCalendarVersion;

  final String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkCommentInput &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'WorkCommentInput[expectedCalendarVersion=$expectedCalendarVersion, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.expectedCalendarVersion != null) {
      json[r'expectedCalendarVersion'] = this.expectedCalendarVersion;
    } else {
      json[r'expectedCalendarVersion'] = null;
    }
      json[r'text'] = this.text;
    return json;
  }

  /// Clones this instance of [WorkCommentInput] and returns a new one where some of the
  /// properties have changed.
  WorkCommentInput copyWith({
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    String? text,
  }) => WorkCommentInput(
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    text: text ?? this.text,
  );

  /// Returns a new [WorkCommentInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkCommentInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "WorkCommentInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'text'), 'Required key "WorkCommentInput[text]" is missing from JSON.');
        assert(json[r'text'] != null, 'Required key "WorkCommentInput[text]" has a null value in JSON.');
        return true;
      }());

      return WorkCommentInput(
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<WorkCommentInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkCommentInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkCommentInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkCommentInput> mapFromJson(dynamic json) {
    final map = <String, WorkCommentInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkCommentInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkCommentInput-objects as value to a dart map
  static Map<String, List<WorkCommentInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkCommentInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkCommentInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedCalendarVersion',
    'text',
  };
}
