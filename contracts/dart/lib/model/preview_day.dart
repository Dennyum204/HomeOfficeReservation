//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PreviewDay {
  /// Returns a new [PreviewDay] instance.
  PreviewDay({
    required this.isWeekend,
    required this.localDate,
  });

  final bool isWeekend;

  final DateTime localDate;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PreviewDay &&
    other.isWeekend == isWeekend &&
    other.localDate == localDate;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (isWeekend.hashCode) +
    (localDate.hashCode);

  @override
  String toString() => 'PreviewDay[isWeekend=$isWeekend, localDate=$localDate]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'isWeekend'] = this.isWeekend;
      json[r'localDate'] = _dateFormatter.format(this.localDate);
    return json;
  }

  /// Clones this instance of [PreviewDay] and returns a new one where some of the
  /// properties have changed.
  PreviewDay copyWith({
    bool? isWeekend,
    DateTime? localDate,
  }) => PreviewDay(
    isWeekend: isWeekend ?? this.isWeekend,
    localDate: localDate ?? this.localDate,
  );

  /// Returns a new [PreviewDay] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PreviewDay? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'isWeekend'), 'Required key "PreviewDay[isWeekend]" is missing from JSON.');
        assert(json[r'isWeekend'] != null, 'Required key "PreviewDay[isWeekend]" has a null value in JSON.');
        assert(json.containsKey(r'localDate'), 'Required key "PreviewDay[localDate]" is missing from JSON.');
        assert(json[r'localDate'] != null, 'Required key "PreviewDay[localDate]" has a null value in JSON.');
        return true;
      }());

      return PreviewDay(
        isWeekend: mapValueOfType<bool>(json, r'isWeekend')!,
        localDate: mapDateTime(json, r'localDate', r'')!,
      );
    }
    return null;
  }

  static List<PreviewDay> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PreviewDay>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PreviewDay.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PreviewDay> mapFromJson(dynamic json) {
    final map = <String, PreviewDay>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PreviewDay.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PreviewDay-objects as value to a dart map
  static Map<String, List<PreviewDay>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PreviewDay>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PreviewDay.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'isWeekend',
    'localDate',
  };
}
