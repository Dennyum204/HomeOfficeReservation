//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DatePreview {
  /// Returns a new [DatePreview] instance.
  DatePreview({
    this.days = const [],
  });

  final List<PreviewDay> days;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DatePreview &&
    _deepEquality.equals(other.days, days);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (days.hashCode);

  @override
  String toString() => 'DatePreview[days=$days]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'days'] = this.days;
    return json;
  }

  /// Clones this instance of [DatePreview] and returns a new one where some of the
  /// properties have changed.
  DatePreview copyWith({
    List<PreviewDay>? days,
  }) => DatePreview(
    days: days ?? this.days,
  );

  /// Returns a new [DatePreview] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DatePreview? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'days'), 'Required key "DatePreview[days]" is missing from JSON.');
        assert(json[r'days'] != null, 'Required key "DatePreview[days]" has a null value in JSON.');
        return true;
      }());

      return DatePreview(
        days: PreviewDay.listFromJson(json[r'days']),
      );
    }
    return null;
  }

  static List<DatePreview> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DatePreview>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DatePreview.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DatePreview> mapFromJson(dynamic json) {
    final map = <String, DatePreview>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DatePreview.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DatePreview-objects as value to a dart map
  static Map<String, List<DatePreview>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DatePreview>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DatePreview.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'days',
  };
}
