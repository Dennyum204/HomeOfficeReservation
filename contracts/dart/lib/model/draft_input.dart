//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DraftInput {
  /// Returns a new [DraftInput] instance.
  DraftInput({
    this.days = const [],
    required this.expectedCalendarVersion,
    required this.expectedRequestVersion,
    required this.note,
    required this.parentRevisionId,
  });

  final List<DayInput> days;

  final int? expectedCalendarVersion;

  final int? expectedRequestVersion;

  final String note;

  final String? parentRevisionId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DraftInput &&
    _deepEquality.equals(other.days, days) &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedRequestVersion == expectedRequestVersion &&
    other.note == note &&
    other.parentRevisionId == parentRevisionId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (days.hashCode) +
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedRequestVersion == null ? 0 : expectedRequestVersion!.hashCode) +
    (note.hashCode) +
    (parentRevisionId == null ? 0 : parentRevisionId!.hashCode);

  @override
  String toString() => 'DraftInput[days=$days, expectedCalendarVersion=$expectedCalendarVersion, expectedRequestVersion=$expectedRequestVersion, note=$note, parentRevisionId=$parentRevisionId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'days'] = this.days;
    if (this.expectedCalendarVersion != null) {
      json[r'expectedCalendarVersion'] = this.expectedCalendarVersion;
    } else {
      json[r'expectedCalendarVersion'] = null;
    }
    if (this.expectedRequestVersion != null) {
      json[r'expectedRequestVersion'] = this.expectedRequestVersion;
    } else {
      json[r'expectedRequestVersion'] = null;
    }
      json[r'note'] = this.note;
    if (this.parentRevisionId != null) {
      json[r'parentRevisionId'] = this.parentRevisionId;
    } else {
      json[r'parentRevisionId'] = null;
    }
    return json;
  }

  /// Clones this instance of [DraftInput] and returns a new one where some of the
  /// properties have changed.
  DraftInput copyWith({
    List<DayInput>? days,
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedRequestVersion,
    bool expectedRequestVersionSetToNull = false,
    String? note,
    String? parentRevisionId,
    bool parentRevisionIdSetToNull = false,
  }) => DraftInput(
    days: days ?? this.days,
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedRequestVersion: expectedRequestVersionSetToNull ? null : expectedRequestVersion ?? this.expectedRequestVersion,
    note: note ?? this.note,
    parentRevisionId: parentRevisionIdSetToNull ? null : parentRevisionId ?? this.parentRevisionId,
  );

  /// Returns a new [DraftInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DraftInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'days'), 'Required key "DraftInput[days]" is missing from JSON.');
        assert(json[r'days'] != null, 'Required key "DraftInput[days]" has a null value in JSON.');
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "DraftInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedRequestVersion'), 'Required key "DraftInput[expectedRequestVersion]" is missing from JSON.');
        assert(json.containsKey(r'note'), 'Required key "DraftInput[note]" is missing from JSON.');
        assert(json[r'note'] != null, 'Required key "DraftInput[note]" has a null value in JSON.');
        assert(json.containsKey(r'parentRevisionId'), 'Required key "DraftInput[parentRevisionId]" is missing from JSON.');
        return true;
      }());

      return DraftInput(
        days: DayInput.listFromJson(json[r'days']),
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedRequestVersion: mapValueOfType<int>(json, r'expectedRequestVersion'),
        note: mapValueOfType<String>(json, r'note')!,
        parentRevisionId: mapValueOfType<String>(json, r'parentRevisionId'),
      );
    }
    return null;
  }

  static List<DraftInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DraftInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DraftInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DraftInput> mapFromJson(dynamic json) {
    final map = <String, DraftInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DraftInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DraftInput-objects as value to a dart map
  static Map<String, List<DraftInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DraftInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DraftInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'days',
    'expectedCalendarVersion',
    'expectedRequestVersion',
    'note',
    'parentRevisionId',
  };
}
