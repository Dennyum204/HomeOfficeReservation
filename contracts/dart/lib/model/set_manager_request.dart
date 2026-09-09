//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SetManagerRequest {
  /// Returns a new [SetManagerRequest] instance.
  SetManagerRequest({
    required this.managerId,
  });

  final String managerId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SetManagerRequest &&
    other.managerId == managerId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (managerId.hashCode);

  @override
  String toString() => 'SetManagerRequest[managerId=$managerId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'managerId'] = this.managerId;
    return json;
  }

  /// Clones this instance of [SetManagerRequest] and returns a new one where some of the
  /// properties have changed.
  SetManagerRequest copyWith({
    String? managerId,
  }) => SetManagerRequest(
    managerId: managerId ?? this.managerId,
  );

  /// Returns a new [SetManagerRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SetManagerRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'managerId'), 'Required key "SetManagerRequest[managerId]" is missing from JSON.');
        assert(json[r'managerId'] != null, 'Required key "SetManagerRequest[managerId]" has a null value in JSON.');
        return true;
      }());

      return SetManagerRequest(
        managerId: mapValueOfType<String>(json, r'managerId')!,
      );
    }
    return null;
  }

  static List<SetManagerRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SetManagerRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SetManagerRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SetManagerRequest> mapFromJson(dynamic json) {
    final map = <String, SetManagerRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SetManagerRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SetManagerRequest-objects as value to a dart map
  static Map<String, List<SetManagerRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SetManagerRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SetManagerRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'managerId',
  };
}
