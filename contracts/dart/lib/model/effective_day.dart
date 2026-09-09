//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EffectiveDay {
  /// Returns a new [EffectiveDay] instance.
  EffectiveDay({
    required this.availability,
    required this.decidedBy,
    required this.localDate,
    required this.location,
    required this.origin,
    required this.sourceDayId,
    required this.sourceRequestId,
    required this.version,
  });

  final Availability? availability;

  final String? decidedBy;

  final DateTime localDate;

  final WorkLocation location;

  final String origin;

  final String? sourceDayId;

  final String? sourceRequestId;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EffectiveDay &&
    other.availability == availability &&
    other.decidedBy == decidedBy &&
    other.localDate == localDate &&
    other.location == location &&
    other.origin == origin &&
    other.sourceDayId == sourceDayId &&
    other.sourceRequestId == sourceRequestId &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (availability == null ? 0 : availability!.hashCode) +
    (decidedBy == null ? 0 : decidedBy!.hashCode) +
    (localDate.hashCode) +
    (location.hashCode) +
    (origin.hashCode) +
    (sourceDayId == null ? 0 : sourceDayId!.hashCode) +
    (sourceRequestId == null ? 0 : sourceRequestId!.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'EffectiveDay[availability=$availability, decidedBy=$decidedBy, localDate=$localDate, location=$location, origin=$origin, sourceDayId=$sourceDayId, sourceRequestId=$sourceRequestId, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.availability != null) {
      json[r'availability'] = this.availability;
    } else {
      json[r'availability'] = null;
    }
    if (this.decidedBy != null) {
      json[r'decidedBy'] = this.decidedBy;
    } else {
      json[r'decidedBy'] = null;
    }
      json[r'localDate'] = _dateFormatter.format(this.localDate);
      json[r'location'] = this.location;
      json[r'origin'] = this.origin;
    if (this.sourceDayId != null) {
      json[r'sourceDayId'] = this.sourceDayId;
    } else {
      json[r'sourceDayId'] = null;
    }
    if (this.sourceRequestId != null) {
      json[r'sourceRequestId'] = this.sourceRequestId;
    } else {
      json[r'sourceRequestId'] = null;
    }
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [EffectiveDay] and returns a new one where some of the
  /// properties have changed.
  EffectiveDay copyWith({
    Availability? availability,
    bool availabilitySetToNull = false,
    String? decidedBy,
    bool decidedBySetToNull = false,
    DateTime? localDate,
    WorkLocation? location,
    String? origin,
    String? sourceDayId,
    bool sourceDayIdSetToNull = false,
    String? sourceRequestId,
    bool sourceRequestIdSetToNull = false,
    int? version,
  }) => EffectiveDay(
    availability: availabilitySetToNull ? null : availability ?? this.availability,
    decidedBy: decidedBySetToNull ? null : decidedBy ?? this.decidedBy,
    localDate: localDate ?? this.localDate,
    location: location ?? this.location,
    origin: origin ?? this.origin,
    sourceDayId: sourceDayIdSetToNull ? null : sourceDayId ?? this.sourceDayId,
    sourceRequestId: sourceRequestIdSetToNull ? null : sourceRequestId ?? this.sourceRequestId,
    version: version ?? this.version,
  );

  /// Returns a new [EffectiveDay] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EffectiveDay? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'availability'), 'Required key "EffectiveDay[availability]" is missing from JSON.');
        assert(json.containsKey(r'decidedBy'), 'Required key "EffectiveDay[decidedBy]" is missing from JSON.');
        assert(json.containsKey(r'localDate'), 'Required key "EffectiveDay[localDate]" is missing from JSON.');
        assert(json[r'localDate'] != null, 'Required key "EffectiveDay[localDate]" has a null value in JSON.');
        assert(json.containsKey(r'location'), 'Required key "EffectiveDay[location]" is missing from JSON.');
        assert(json[r'location'] != null, 'Required key "EffectiveDay[location]" has a null value in JSON.');
        assert(json.containsKey(r'origin'), 'Required key "EffectiveDay[origin]" is missing from JSON.');
        assert(json[r'origin'] != null, 'Required key "EffectiveDay[origin]" has a null value in JSON.');
        assert(json.containsKey(r'sourceDayId'), 'Required key "EffectiveDay[sourceDayId]" is missing from JSON.');
        assert(json.containsKey(r'sourceRequestId'), 'Required key "EffectiveDay[sourceRequestId]" is missing from JSON.');
        assert(json.containsKey(r'version'), 'Required key "EffectiveDay[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "EffectiveDay[version]" has a null value in JSON.');
        return true;
      }());

      return EffectiveDay(
        availability: Availability.fromJson(json[r'availability']),
        decidedBy: mapValueOfType<String>(json, r'decidedBy'),
        localDate: mapDateTime(json, r'localDate', r'')!,
        location: WorkLocation.fromJson(json[r'location'])!,
        origin: mapValueOfType<String>(json, r'origin')!,
        sourceDayId: mapValueOfType<String>(json, r'sourceDayId'),
        sourceRequestId: mapValueOfType<String>(json, r'sourceRequestId'),
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<EffectiveDay> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EffectiveDay>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EffectiveDay.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EffectiveDay> mapFromJson(dynamic json) {
    final map = <String, EffectiveDay>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EffectiveDay.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EffectiveDay-objects as value to a dart map
  static Map<String, List<EffectiveDay>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EffectiveDay>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EffectiveDay.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'availability',
    'decidedBy',
    'localDate',
    'location',
    'origin',
    'sourceDayId',
    'sourceRequestId',
    'version',
  };
}
