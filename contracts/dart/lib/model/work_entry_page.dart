//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WorkEntryPage {
  /// Returns a new [WorkEntryPage] instance.
  WorkEntryPage({
    this.items = const [],
    required this.nextOffset,
  });

  final List<WorkEntryView> items;

  final int? nextOffset;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkEntryPage &&
    _deepEquality.equals(other.items, items) &&
    other.nextOffset == nextOffset;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (nextOffset == null ? 0 : nextOffset!.hashCode);

  @override
  String toString() => 'WorkEntryPage[items=$items, nextOffset=$nextOffset]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
    if (this.nextOffset != null) {
      json[r'nextOffset'] = this.nextOffset;
    } else {
      json[r'nextOffset'] = null;
    }
    return json;
  }

  /// Clones this instance of [WorkEntryPage] and returns a new one where some of the
  /// properties have changed.
  WorkEntryPage copyWith({
    List<WorkEntryView>? items,
    int? nextOffset,
    bool nextOffsetSetToNull = false,
  }) => WorkEntryPage(
    items: items ?? this.items,
    nextOffset: nextOffsetSetToNull ? null : nextOffset ?? this.nextOffset,
  );

  /// Returns a new [WorkEntryPage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkEntryPage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'items'), 'Required key "WorkEntryPage[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "WorkEntryPage[items]" has a null value in JSON.');
        assert(json.containsKey(r'nextOffset'), 'Required key "WorkEntryPage[nextOffset]" is missing from JSON.');
        return true;
      }());

      return WorkEntryPage(
        items: WorkEntryView.listFromJson(json[r'items']),
        nextOffset: mapValueOfType<int>(json, r'nextOffset'),
      );
    }
    return null;
  }

  static List<WorkEntryPage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkEntryPage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkEntryPage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkEntryPage> mapFromJson(dynamic json) {
    final map = <String, WorkEntryPage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkEntryPage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkEntryPage-objects as value to a dart map
  static Map<String, List<WorkEntryPage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkEntryPage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkEntryPage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'nextOffset',
  };
}
