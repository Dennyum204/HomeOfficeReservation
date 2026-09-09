//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TaskView {
  /// Returns a new [TaskView] instance.
  TaskView({
    required this.deadline,
    required this.description,
    required this.employeeId,
    required this.id,
    required this.progressNote,
    required this.requirementId,
    required this.requirementRevision,
    required this.requirementState,
    required this.requiresOnsite,
    required this.state,
    required this.title,
    required this.version,
  });

  final DateTime deadline;

  final String description;

  final String employeeId;

  final String id;

  final String progressNote;

  final String? requirementId;

  final int? requirementRevision;

  final OnsiteState? requirementState;

  final bool requiresOnsite;

  final AssignedTaskState state;

  final String title;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TaskView &&
    other.deadline == deadline &&
    other.description == description &&
    other.employeeId == employeeId &&
    other.id == id &&
    other.progressNote == progressNote &&
    other.requirementId == requirementId &&
    other.requirementRevision == requirementRevision &&
    other.requirementState == requirementState &&
    other.requiresOnsite == requiresOnsite &&
    other.state == state &&
    other.title == title &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deadline.hashCode) +
    (description.hashCode) +
    (employeeId.hashCode) +
    (id.hashCode) +
    (progressNote.hashCode) +
    (requirementId == null ? 0 : requirementId!.hashCode) +
    (requirementRevision == null ? 0 : requirementRevision!.hashCode) +
    (requirementState == null ? 0 : requirementState!.hashCode) +
    (requiresOnsite.hashCode) +
    (state.hashCode) +
    (title.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'TaskView[deadline=$deadline, description=$description, employeeId=$employeeId, id=$id, progressNote=$progressNote, requirementId=$requirementId, requirementRevision=$requirementRevision, requirementState=$requirementState, requiresOnsite=$requiresOnsite, state=$state, title=$title, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deadline'] = _dateFormatter.format(this.deadline);
      json[r'description'] = this.description;
      json[r'employeeId'] = this.employeeId;
      json[r'id'] = this.id;
      json[r'progressNote'] = this.progressNote;
    if (this.requirementId != null) {
      json[r'requirementId'] = this.requirementId;
    } else {
      json[r'requirementId'] = null;
    }
    if (this.requirementRevision != null) {
      json[r'requirementRevision'] = this.requirementRevision;
    } else {
      json[r'requirementRevision'] = null;
    }
    if (this.requirementState != null) {
      json[r'requirementState'] = this.requirementState;
    } else {
      json[r'requirementState'] = null;
    }
      json[r'requiresOnsite'] = this.requiresOnsite;
      json[r'state'] = this.state;
      json[r'title'] = this.title;
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [TaskView] and returns a new one where some of the
  /// properties have changed.
  TaskView copyWith({
    DateTime? deadline,
    String? description,
    String? employeeId,
    String? id,
    String? progressNote,
    String? requirementId,
    bool requirementIdSetToNull = false,
    int? requirementRevision,
    bool requirementRevisionSetToNull = false,
    OnsiteState? requirementState,
    bool requirementStateSetToNull = false,
    bool? requiresOnsite,
    AssignedTaskState? state,
    String? title,
    int? version,
  }) => TaskView(
    deadline: deadline ?? this.deadline,
    description: description ?? this.description,
    employeeId: employeeId ?? this.employeeId,
    id: id ?? this.id,
    progressNote: progressNote ?? this.progressNote,
    requirementId: requirementIdSetToNull ? null : requirementId ?? this.requirementId,
    requirementRevision: requirementRevisionSetToNull ? null : requirementRevision ?? this.requirementRevision,
    requirementState: requirementStateSetToNull ? null : requirementState ?? this.requirementState,
    requiresOnsite: requiresOnsite ?? this.requiresOnsite,
    state: state ?? this.state,
    title: title ?? this.title,
    version: version ?? this.version,
  );

  /// Returns a new [TaskView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TaskView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deadline'), 'Required key "TaskView[deadline]" is missing from JSON.');
        assert(json[r'deadline'] != null, 'Required key "TaskView[deadline]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "TaskView[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "TaskView[description]" has a null value in JSON.');
        assert(json.containsKey(r'employeeId'), 'Required key "TaskView[employeeId]" is missing from JSON.');
        assert(json[r'employeeId'] != null, 'Required key "TaskView[employeeId]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "TaskView[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "TaskView[id]" has a null value in JSON.');
        assert(json.containsKey(r'progressNote'), 'Required key "TaskView[progressNote]" is missing from JSON.');
        assert(json[r'progressNote'] != null, 'Required key "TaskView[progressNote]" has a null value in JSON.');
        assert(json.containsKey(r'requirementId'), 'Required key "TaskView[requirementId]" is missing from JSON.');
        assert(json.containsKey(r'requirementRevision'), 'Required key "TaskView[requirementRevision]" is missing from JSON.');
        assert(json.containsKey(r'requirementState'), 'Required key "TaskView[requirementState]" is missing from JSON.');
        assert(json.containsKey(r'requiresOnsite'), 'Required key "TaskView[requiresOnsite]" is missing from JSON.');
        assert(json[r'requiresOnsite'] != null, 'Required key "TaskView[requiresOnsite]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "TaskView[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "TaskView[state]" has a null value in JSON.');
        assert(json.containsKey(r'title'), 'Required key "TaskView[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "TaskView[title]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "TaskView[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "TaskView[version]" has a null value in JSON.');
        return true;
      }());

      return TaskView(
        deadline: mapDateTime(json, r'deadline', r'')!,
        description: mapValueOfType<String>(json, r'description')!,
        employeeId: mapValueOfType<String>(json, r'employeeId')!,
        id: mapValueOfType<String>(json, r'id')!,
        progressNote: mapValueOfType<String>(json, r'progressNote')!,
        requirementId: mapValueOfType<String>(json, r'requirementId'),
        requirementRevision: mapValueOfType<int>(json, r'requirementRevision'),
        requirementState: OnsiteState.fromJson(json[r'requirementState']),
        requiresOnsite: mapValueOfType<bool>(json, r'requiresOnsite')!,
        state: AssignedTaskState.fromJson(json[r'state'])!,
        title: mapValueOfType<String>(json, r'title')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<TaskView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TaskView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TaskView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TaskView> mapFromJson(dynamic json) {
    final map = <String, TaskView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TaskView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TaskView-objects as value to a dart map
  static Map<String, List<TaskView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TaskView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TaskView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deadline',
    'description',
    'employeeId',
    'id',
    'progressNote',
    'requirementId',
    'requirementRevision',
    'requirementState',
    'requiresOnsite',
    'state',
    'title',
    'version',
  };
}
