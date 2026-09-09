//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SelectedDay {
  /// Returns a new [SelectedDay] instance.
  SelectedDay({
    required this.dayId,
    required this.expectedVersion,
  });

  final String dayId;

  final int? expectedVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SelectedDay &&
    other.dayId == dayId &&
    other.expectedVersion == expectedVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (dayId.hashCode) +
    (expectedVersion == null ? 0 : expectedVersion!.hashCode);

  @override
  String toString() => 'SelectedDay[dayId=$dayId, expectedVersion=$expectedVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'dayId'] = this.dayId;
    if (this.expectedVersion != null) {
      json[r'expectedVersion'] = this.expectedVersion;
    } else {
      json[r'expectedVersion'] = null;
    }
    return json;
  }

  /// Clones this instance of [SelectedDay] and returns a new one where some of the
  /// properties have changed.
  SelectedDay copyWith({
    String? dayId,
    int? expectedVersion,
    bool expectedVersionSetToNull = false,
  }) => SelectedDay(
    dayId: dayId ?? this.dayId,
    expectedVersion: expectedVersionSetToNull ? null : expectedVersion ?? this.expectedVersion,
  );

  /// Returns a new [SelectedDay] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SelectedDay? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'dayId'), 'Required key "SelectedDay[dayId]" is missing from JSON.');
        assert(json[r'dayId'] != null, 'Required key "SelectedDay[dayId]" has a null value in JSON.');
        assert(json.containsKey(r'expectedVersion'), 'Required key "SelectedDay[expectedVersion]" is missing from JSON.');
        return true;
      }());

      return SelectedDay(
        dayId: mapValueOfType<String>(json, r'dayId')!,
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion'),
      );
    }
    return null;
  }

  static List<SelectedDay> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SelectedDay>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SelectedDay.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SelectedDay> mapFromJson(dynamic json) {
    final map = <String, SelectedDay>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SelectedDay.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SelectedDay-objects as value to a dart map
  static Map<String, List<SelectedDay>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SelectedDay>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SelectedDay.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'dayId',
    'expectedVersion',
  };
}
