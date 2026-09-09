//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PendingDay {
  /// Returns a new [PendingDay] instance.
  PendingDay({
    required this.day,
    required this.requestId,
    required this.requestVersion,
  });

  final RequestedDayView day;

  final String requestId;

  final int requestVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PendingDay &&
    other.day == day &&
    other.requestId == requestId &&
    other.requestVersion == requestVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (day.hashCode) +
    (requestId.hashCode) +
    (requestVersion.hashCode);

  @override
  String toString() => 'PendingDay[day=$day, requestId=$requestId, requestVersion=$requestVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'day'] = this.day;
      json[r'requestId'] = this.requestId;
      json[r'requestVersion'] = this.requestVersion;
    return json;
  }

  /// Clones this instance of [PendingDay] and returns a new one where some of the
  /// properties have changed.
  PendingDay copyWith({
    RequestedDayView? day,
    String? requestId,
    int? requestVersion,
  }) => PendingDay(
    day: day ?? this.day,
    requestId: requestId ?? this.requestId,
    requestVersion: requestVersion ?? this.requestVersion,
  );

  /// Returns a new [PendingDay] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PendingDay? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'day'), 'Required key "PendingDay[day]" is missing from JSON.');
        assert(json[r'day'] != null, 'Required key "PendingDay[day]" has a null value in JSON.');
        assert(json.containsKey(r'requestId'), 'Required key "PendingDay[requestId]" is missing from JSON.');
        assert(json[r'requestId'] != null, 'Required key "PendingDay[requestId]" has a null value in JSON.');
        assert(json.containsKey(r'requestVersion'), 'Required key "PendingDay[requestVersion]" is missing from JSON.');
        assert(json[r'requestVersion'] != null, 'Required key "PendingDay[requestVersion]" has a null value in JSON.');
        return true;
      }());

      return PendingDay(
        day: RequestedDayView.fromJson(json[r'day'])!,
        requestId: mapValueOfType<String>(json, r'requestId')!,
        requestVersion: mapValueOfType<int>(json, r'requestVersion')!,
      );
    }
    return null;
  }

  static List<PendingDay> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PendingDay>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PendingDay.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PendingDay> mapFromJson(dynamic json) {
    final map = <String, PendingDay>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PendingDay.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PendingDay-objects as value to a dart map
  static Map<String, List<PendingDay>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PendingDay>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PendingDay.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'day',
    'requestId',
    'requestVersion',
  };
}
