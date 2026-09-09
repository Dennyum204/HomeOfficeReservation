//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TaskProgressInput {
  /// Returns a new [TaskProgressInput] instance.
  TaskProgressInput({
    required this.expectedCalendarVersion,
    required this.expectedVersion,
    required this.note,
    required this.state,
  });

  final int? expectedCalendarVersion;

  final int? expectedVersion;

  final String note;

  final AssignedTaskState state;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TaskProgressInput &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedVersion == expectedVersion &&
    other.note == note &&
    other.state == state;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedVersion == null ? 0 : expectedVersion!.hashCode) +
    (note.hashCode) +
    (state.hashCode);

  @override
  String toString() => 'TaskProgressInput[expectedCalendarVersion=$expectedCalendarVersion, expectedVersion=$expectedVersion, note=$note, state=$state]';

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
      json[r'note'] = this.note;
      json[r'state'] = this.state;
    return json;
  }

  /// Clones this instance of [TaskProgressInput] and returns a new one where some of the
  /// properties have changed.
  TaskProgressInput copyWith({
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedVersion,
    bool expectedVersionSetToNull = false,
    String? note,
    AssignedTaskState? state,
  }) => TaskProgressInput(
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedVersion: expectedVersionSetToNull ? null : expectedVersion ?? this.expectedVersion,
    note: note ?? this.note,
    state: state ?? this.state,
  );

  /// Returns a new [TaskProgressInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TaskProgressInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "TaskProgressInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedVersion'), 'Required key "TaskProgressInput[expectedVersion]" is missing from JSON.');
        assert(json.containsKey(r'note'), 'Required key "TaskProgressInput[note]" is missing from JSON.');
        assert(json[r'note'] != null, 'Required key "TaskProgressInput[note]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "TaskProgressInput[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "TaskProgressInput[state]" has a null value in JSON.');
        return true;
      }());

      return TaskProgressInput(
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion'),
        note: mapValueOfType<String>(json, r'note')!,
        state: AssignedTaskState.fromJson(json[r'state'])!,
      );
    }
    return null;
  }

  static List<TaskProgressInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TaskProgressInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TaskProgressInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TaskProgressInput> mapFromJson(dynamic json) {
    final map = <String, TaskProgressInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TaskProgressInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TaskProgressInput-objects as value to a dart map
  static Map<String, List<TaskProgressInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TaskProgressInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TaskProgressInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedCalendarVersion',
    'expectedVersion',
    'note',
    'state',
  };
}
