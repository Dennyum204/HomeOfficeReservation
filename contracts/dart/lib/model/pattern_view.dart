//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PatternView {
  /// Returns a new [PatternView] instance.
  PatternView({
    required this.effectiveFrom,
    this.locations = const [],
    required this.version,
  });

  final DateTime effectiveFrom;

  final List<WorkLocation> locations;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PatternView &&
    other.effectiveFrom == effectiveFrom &&
    _deepEquality.equals(other.locations, locations) &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (effectiveFrom.hashCode) +
    (locations.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'PatternView[effectiveFrom=$effectiveFrom, locations=$locations, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'effectiveFrom'] = _dateFormatter.format(this.effectiveFrom);
      json[r'locations'] = this.locations;
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [PatternView] and returns a new one where some of the
  /// properties have changed.
  PatternView copyWith({
    DateTime? effectiveFrom,
    List<WorkLocation>? locations,
    int? version,
  }) => PatternView(
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    locations: locations ?? this.locations,
    version: version ?? this.version,
  );

  /// Returns a new [PatternView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PatternView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'effectiveFrom'), 'Required key "PatternView[effectiveFrom]" is missing from JSON.');
        assert(json[r'effectiveFrom'] != null, 'Required key "PatternView[effectiveFrom]" has a null value in JSON.');
        assert(json.containsKey(r'locations'), 'Required key "PatternView[locations]" is missing from JSON.');
        assert(json[r'locations'] != null, 'Required key "PatternView[locations]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "PatternView[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "PatternView[version]" has a null value in JSON.');
        return true;
      }());

      return PatternView(
        effectiveFrom: mapDateTime(json, r'effectiveFrom', r'')!,
        locations: WorkLocation.listFromJson(json[r'locations']),
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<PatternView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PatternView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PatternView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PatternView> mapFromJson(dynamic json) {
    final map = <String, PatternView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PatternView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PatternView-objects as value to a dart map
  static Map<String, List<PatternView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PatternView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PatternView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'effectiveFrom',
    'locations',
    'version',
  };
}
