//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PatternPage {
  /// Returns a new [PatternPage] instance.
  PatternPage({
    required this.calendarVersion,
    this.items = const [],
    required this.nextOffset,
  });

  final int calendarVersion;

  final List<PatternView> items;

  final int? nextOffset;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PatternPage &&
    other.calendarVersion == calendarVersion &&
    _deepEquality.equals(other.items, items) &&
    other.nextOffset == nextOffset;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (calendarVersion.hashCode) +
    (items.hashCode) +
    (nextOffset == null ? 0 : nextOffset!.hashCode);

  @override
  String toString() => 'PatternPage[calendarVersion=$calendarVersion, items=$items, nextOffset=$nextOffset]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'calendarVersion'] = this.calendarVersion;
      json[r'items'] = this.items;
    if (this.nextOffset != null) {
      json[r'nextOffset'] = this.nextOffset;
    } else {
      json[r'nextOffset'] = null;
    }
    return json;
  }

  /// Clones this instance of [PatternPage] and returns a new one where some of the
  /// properties have changed.
  PatternPage copyWith({
    int? calendarVersion,
    List<PatternView>? items,
    int? nextOffset,
    bool nextOffsetSetToNull = false,
  }) => PatternPage(
    calendarVersion: calendarVersion ?? this.calendarVersion,
    items: items ?? this.items,
    nextOffset: nextOffsetSetToNull ? null : nextOffset ?? this.nextOffset,
  );

  /// Returns a new [PatternPage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PatternPage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'calendarVersion'), 'Required key "PatternPage[calendarVersion]" is missing from JSON.');
        assert(json[r'calendarVersion'] != null, 'Required key "PatternPage[calendarVersion]" has a null value in JSON.');
        assert(json.containsKey(r'items'), 'Required key "PatternPage[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "PatternPage[items]" has a null value in JSON.');
        assert(json.containsKey(r'nextOffset'), 'Required key "PatternPage[nextOffset]" is missing from JSON.');
        return true;
      }());

      return PatternPage(
        calendarVersion: mapValueOfType<int>(json, r'calendarVersion')!,
        items: PatternView.listFromJson(json[r'items']),
        nextOffset: mapValueOfType<int>(json, r'nextOffset'),
      );
    }
    return null;
  }

  static List<PatternPage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PatternPage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PatternPage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PatternPage> mapFromJson(dynamic json) {
    final map = <String, PatternPage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PatternPage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PatternPage-objects as value to a dart map
  static Map<String, List<PatternPage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PatternPage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PatternPage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'calendarVersion',
    'items',
    'nextOffset',
  };
}
