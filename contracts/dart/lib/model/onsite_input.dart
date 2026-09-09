//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OnsiteInput {
  /// Returns a new [OnsiteInput] instance.
  OnsiteInput({
    required this.expectedCalendarVersion,
    required this.expectedVersion,
    required this.from,
    required this.location,
    required this.reason,
    required this.reference,
    required this.to,
  });

  final int? expectedCalendarVersion;

  final int? expectedVersion;

  final DateTime from;

  final String location;

  final String reason;

  final String reference;

  final DateTime to;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OnsiteInput &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedVersion == expectedVersion &&
    other.from == from &&
    other.location == location &&
    other.reason == reason &&
    other.reference == reference &&
    other.to == to;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedVersion == null ? 0 : expectedVersion!.hashCode) +
    (from.hashCode) +
    (location.hashCode) +
    (reason.hashCode) +
    (reference.hashCode) +
    (to.hashCode);

  @override
  String toString() => 'OnsiteInput[expectedCalendarVersion=$expectedCalendarVersion, expectedVersion=$expectedVersion, from=$from, location=$location, reason=$reason, reference=$reference, to=$to]';

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
      json[r'from'] = _dateFormatter.format(this.from);
      json[r'location'] = this.location;
      json[r'reason'] = this.reason;
      json[r'reference'] = this.reference;
      json[r'to'] = _dateFormatter.format(this.to);
    return json;
  }

  /// Clones this instance of [OnsiteInput] and returns a new one where some of the
  /// properties have changed.
  OnsiteInput copyWith({
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedVersion,
    bool expectedVersionSetToNull = false,
    DateTime? from,
    String? location,
    String? reason,
    String? reference,
    DateTime? to,
  }) => OnsiteInput(
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedVersion: expectedVersionSetToNull ? null : expectedVersion ?? this.expectedVersion,
    from: from ?? this.from,
    location: location ?? this.location,
    reason: reason ?? this.reason,
    reference: reference ?? this.reference,
    to: to ?? this.to,
  );

  /// Returns a new [OnsiteInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OnsiteInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "OnsiteInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedVersion'), 'Required key "OnsiteInput[expectedVersion]" is missing from JSON.');
        assert(json.containsKey(r'from'), 'Required key "OnsiteInput[from]" is missing from JSON.');
        assert(json[r'from'] != null, 'Required key "OnsiteInput[from]" has a null value in JSON.');
        assert(json.containsKey(r'location'), 'Required key "OnsiteInput[location]" is missing from JSON.');
        assert(json[r'location'] != null, 'Required key "OnsiteInput[location]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "OnsiteInput[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "OnsiteInput[reason]" has a null value in JSON.');
        assert(json.containsKey(r'reference'), 'Required key "OnsiteInput[reference]" is missing from JSON.');
        assert(json[r'reference'] != null, 'Required key "OnsiteInput[reference]" has a null value in JSON.');
        assert(json.containsKey(r'to'), 'Required key "OnsiteInput[to]" is missing from JSON.');
        assert(json[r'to'] != null, 'Required key "OnsiteInput[to]" has a null value in JSON.');
        return true;
      }());

      return OnsiteInput(
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion'),
        from: mapDateTime(json, r'from', r'')!,
        location: mapValueOfType<String>(json, r'location')!,
        reason: mapValueOfType<String>(json, r'reason')!,
        reference: mapValueOfType<String>(json, r'reference')!,
        to: mapDateTime(json, r'to', r'')!,
      );
    }
    return null;
  }

  static List<OnsiteInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OnsiteInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OnsiteInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OnsiteInput> mapFromJson(dynamic json) {
    final map = <String, OnsiteInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OnsiteInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OnsiteInput-objects as value to a dart map
  static Map<String, List<OnsiteInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OnsiteInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OnsiteInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedCalendarVersion',
    'expectedVersion',
    'from',
    'location',
    'reason',
    'reference',
    'to',
  };
}
