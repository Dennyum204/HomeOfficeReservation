//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DayInput {
  /// Returns a new [DayInput] instance.
  DayInput({
    required this.availability,
    this.baseDayId,
    this.basePlanVersion,
    this.cancel = false,
    required this.localDate,
    required this.location,
  });

  final Availability availability;

  final String? baseDayId;

  final int? basePlanVersion;

  final bool cancel;

  final DateTime localDate;

  final WorkLocation location;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DayInput &&
    other.availability == availability &&
    other.baseDayId == baseDayId &&
    other.basePlanVersion == basePlanVersion &&
    other.cancel == cancel &&
    other.localDate == localDate &&
    other.location == location;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (availability.hashCode) +
    (baseDayId == null ? 0 : baseDayId!.hashCode) +
    (basePlanVersion == null ? 0 : basePlanVersion!.hashCode) +
    (cancel.hashCode) +
    (localDate.hashCode) +
    (location.hashCode);

  @override
  String toString() => 'DayInput[availability=$availability, baseDayId=$baseDayId, basePlanVersion=$basePlanVersion, cancel=$cancel, localDate=$localDate, location=$location]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'availability'] = this.availability;
    if (this.baseDayId != null) {
      json[r'baseDayId'] = this.baseDayId;
    } else {
      json[r'baseDayId'] = null;
    }
    if (this.basePlanVersion != null) {
      json[r'basePlanVersion'] = this.basePlanVersion;
    } else {
      json[r'basePlanVersion'] = null;
    }
      json[r'cancel'] = this.cancel;
      json[r'localDate'] = _dateFormatter.format(this.localDate);
      json[r'location'] = this.location;
    return json;
  }

  /// Clones this instance of [DayInput] and returns a new one where some of the
  /// properties have changed.
  DayInput copyWith({
    Availability? availability,
    String? baseDayId,
    bool baseDayIdSetToNull = false,
    int? basePlanVersion,
    bool basePlanVersionSetToNull = false,
    bool? cancel,
    DateTime? localDate,
    WorkLocation? location,
  }) => DayInput(
    availability: availability ?? this.availability,
    baseDayId: baseDayIdSetToNull ? null : baseDayId ?? this.baseDayId,
    basePlanVersion: basePlanVersionSetToNull ? null : basePlanVersion ?? this.basePlanVersion,
    cancel: cancel ?? this.cancel,
    localDate: localDate ?? this.localDate,
    location: location ?? this.location,
  );

  /// Returns a new [DayInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DayInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'availability'), 'Required key "DayInput[availability]" is missing from JSON.');
        assert(json[r'availability'] != null, 'Required key "DayInput[availability]" has a null value in JSON.');
        assert(json.containsKey(r'localDate'), 'Required key "DayInput[localDate]" is missing from JSON.');
        assert(json[r'localDate'] != null, 'Required key "DayInput[localDate]" has a null value in JSON.');
        assert(json.containsKey(r'location'), 'Required key "DayInput[location]" is missing from JSON.');
        assert(json[r'location'] != null, 'Required key "DayInput[location]" has a null value in JSON.');
        return true;
      }());

      return DayInput(
        availability: Availability.fromJson(json[r'availability'])!,
        baseDayId: mapValueOfType<String>(json, r'baseDayId'),
        basePlanVersion: mapValueOfType<int>(json, r'basePlanVersion'),
        cancel: mapValueOfType<bool>(json, r'cancel') ?? false,
        localDate: mapDateTime(json, r'localDate', r'')!,
        location: WorkLocation.fromJson(json[r'location'])!,
      );
    }
    return null;
  }

  static List<DayInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DayInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DayInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DayInput> mapFromJson(dynamic json) {
    final map = <String, DayInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DayInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DayInput-objects as value to a dart map
  static Map<String, List<DayInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DayInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DayInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'availability',
    'localDate',
    'location',
  };
}
