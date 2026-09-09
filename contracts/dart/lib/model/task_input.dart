//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TaskInput {
  /// Returns a new [TaskInput] instance.
  TaskInput({
    required this.deadline,
    required this.description,
    required this.expectedCalendarVersion,
    required this.expectedVersion,
    required this.requirementId,
    required this.requiresOnsite,
    required this.state,
    required this.title,
  });

  final DateTime deadline;

  final String description;

  final int? expectedCalendarVersion;

  final int? expectedVersion;

  final String? requirementId;

  final bool requiresOnsite;

  final AssignedTaskState state;

  final String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TaskInput &&
    other.deadline == deadline &&
    other.description == description &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedVersion == expectedVersion &&
    other.requirementId == requirementId &&
    other.requiresOnsite == requiresOnsite &&
    other.state == state &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deadline.hashCode) +
    (description.hashCode) +
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedVersion == null ? 0 : expectedVersion!.hashCode) +
    (requirementId == null ? 0 : requirementId!.hashCode) +
    (requiresOnsite.hashCode) +
    (state.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'TaskInput[deadline=$deadline, description=$description, expectedCalendarVersion=$expectedCalendarVersion, expectedVersion=$expectedVersion, requirementId=$requirementId, requiresOnsite=$requiresOnsite, state=$state, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deadline'] = _dateFormatter.format(this.deadline);
      json[r'description'] = this.description;
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
    if (this.requirementId != null) {
      json[r'requirementId'] = this.requirementId;
    } else {
      json[r'requirementId'] = null;
    }
      json[r'requiresOnsite'] = this.requiresOnsite;
      json[r'state'] = this.state;
      json[r'title'] = this.title;
    return json;
  }

  /// Clones this instance of [TaskInput] and returns a new one where some of the
  /// properties have changed.
  TaskInput copyWith({
    DateTime? deadline,
    String? description,
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedVersion,
    bool expectedVersionSetToNull = false,
    String? requirementId,
    bool requirementIdSetToNull = false,
    bool? requiresOnsite,
    AssignedTaskState? state,
    String? title,
  }) => TaskInput(
    deadline: deadline ?? this.deadline,
    description: description ?? this.description,
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedVersion: expectedVersionSetToNull ? null : expectedVersion ?? this.expectedVersion,
    requirementId: requirementIdSetToNull ? null : requirementId ?? this.requirementId,
    requiresOnsite: requiresOnsite ?? this.requiresOnsite,
    state: state ?? this.state,
    title: title ?? this.title,
  );

  /// Returns a new [TaskInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TaskInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deadline'), 'Required key "TaskInput[deadline]" is missing from JSON.');
        assert(json[r'deadline'] != null, 'Required key "TaskInput[deadline]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "TaskInput[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "TaskInput[description]" has a null value in JSON.');
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "TaskInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedVersion'), 'Required key "TaskInput[expectedVersion]" is missing from JSON.');
        assert(json.containsKey(r'requirementId'), 'Required key "TaskInput[requirementId]" is missing from JSON.');
        assert(json.containsKey(r'requiresOnsite'), 'Required key "TaskInput[requiresOnsite]" is missing from JSON.');
        assert(json[r'requiresOnsite'] != null, 'Required key "TaskInput[requiresOnsite]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "TaskInput[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "TaskInput[state]" has a null value in JSON.');
        assert(json.containsKey(r'title'), 'Required key "TaskInput[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "TaskInput[title]" has a null value in JSON.');
        return true;
      }());

      return TaskInput(
        deadline: mapDateTime(json, r'deadline', r'')!,
        description: mapValueOfType<String>(json, r'description')!,
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion'),
        requirementId: mapValueOfType<String>(json, r'requirementId'),
        requiresOnsite: mapValueOfType<bool>(json, r'requiresOnsite')!,
        state: AssignedTaskState.fromJson(json[r'state'])!,
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<TaskInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TaskInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TaskInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TaskInput> mapFromJson(dynamic json) {
    final map = <String, TaskInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TaskInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TaskInput-objects as value to a dart map
  static Map<String, List<TaskInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TaskInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TaskInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deadline',
    'description',
    'expectedCalendarVersion',
    'expectedVersion',
    'requirementId',
    'requiresOnsite',
    'state',
    'title',
  };
}
