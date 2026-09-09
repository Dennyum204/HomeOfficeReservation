//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WorkEntryView {
  /// Returns a new [WorkEntryView] instance.
  WorkEntryView({
    required this.action,
    required this.authorId,
    required this.calendarVersion,
    required this.createdAt,
    required this.id,
    required this.snapshotJson,
    required this.text,
  });

  final String action;

  final String authorId;

  final int calendarVersion;

  final DateTime createdAt;

  final String id;

  final String snapshotJson;

  final String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkEntryView &&
    other.action == action &&
    other.authorId == authorId &&
    other.calendarVersion == calendarVersion &&
    other.createdAt == createdAt &&
    other.id == id &&
    other.snapshotJson == snapshotJson &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (action.hashCode) +
    (authorId.hashCode) +
    (calendarVersion.hashCode) +
    (createdAt.hashCode) +
    (id.hashCode) +
    (snapshotJson.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'WorkEntryView[action=$action, authorId=$authorId, calendarVersion=$calendarVersion, createdAt=$createdAt, id=$id, snapshotJson=$snapshotJson, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'action'] = this.action;
      json[r'authorId'] = this.authorId;
      json[r'calendarVersion'] = this.calendarVersion;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'id'] = this.id;
      json[r'snapshotJson'] = this.snapshotJson;
      json[r'text'] = this.text;
    return json;
  }

  /// Clones this instance of [WorkEntryView] and returns a new one where some of the
  /// properties have changed.
  WorkEntryView copyWith({
    String? action,
    String? authorId,
    int? calendarVersion,
    DateTime? createdAt,
    String? id,
    String? snapshotJson,
    String? text,
  }) => WorkEntryView(
    action: action ?? this.action,
    authorId: authorId ?? this.authorId,
    calendarVersion: calendarVersion ?? this.calendarVersion,
    createdAt: createdAt ?? this.createdAt,
    id: id ?? this.id,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    text: text ?? this.text,
  );

  /// Returns a new [WorkEntryView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkEntryView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'action'), 'Required key "WorkEntryView[action]" is missing from JSON.');
        assert(json[r'action'] != null, 'Required key "WorkEntryView[action]" has a null value in JSON.');
        assert(json.containsKey(r'authorId'), 'Required key "WorkEntryView[authorId]" is missing from JSON.');
        assert(json[r'authorId'] != null, 'Required key "WorkEntryView[authorId]" has a null value in JSON.');
        assert(json.containsKey(r'calendarVersion'), 'Required key "WorkEntryView[calendarVersion]" is missing from JSON.');
        assert(json[r'calendarVersion'] != null, 'Required key "WorkEntryView[calendarVersion]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "WorkEntryView[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "WorkEntryView[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "WorkEntryView[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "WorkEntryView[id]" has a null value in JSON.');
        assert(json.containsKey(r'snapshotJson'), 'Required key "WorkEntryView[snapshotJson]" is missing from JSON.');
        assert(json[r'snapshotJson'] != null, 'Required key "WorkEntryView[snapshotJson]" has a null value in JSON.');
        assert(json.containsKey(r'text'), 'Required key "WorkEntryView[text]" is missing from JSON.');
        assert(json[r'text'] != null, 'Required key "WorkEntryView[text]" has a null value in JSON.');
        return true;
      }());

      return WorkEntryView(
        action: mapValueOfType<String>(json, r'action')!,
        authorId: mapValueOfType<String>(json, r'authorId')!,
        calendarVersion: mapValueOfType<int>(json, r'calendarVersion')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        id: mapValueOfType<String>(json, r'id')!,
        snapshotJson: mapValueOfType<String>(json, r'snapshotJson')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<WorkEntryView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkEntryView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkEntryView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkEntryView> mapFromJson(dynamic json) {
    final map = <String, WorkEntryView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkEntryView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkEntryView-objects as value to a dart map
  static Map<String, List<WorkEntryView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkEntryView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkEntryView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'action',
    'authorId',
    'calendarVersion',
    'createdAt',
    'id',
    'snapshotJson',
    'text',
  };
}
