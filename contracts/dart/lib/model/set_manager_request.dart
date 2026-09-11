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
    this.commandId,
    this.expectedAccessVersion,
    required this.managerId,
  });

  final String? commandId;

  final int? expectedAccessVersion;

  final String? managerId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SetManagerRequest &&
    other.commandId == commandId &&
    other.expectedAccessVersion == expectedAccessVersion &&
    other.managerId == managerId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (commandId == null ? 0 : commandId!.hashCode) +
    (expectedAccessVersion == null ? 0 : expectedAccessVersion!.hashCode) +
    (managerId == null ? 0 : managerId!.hashCode);

  @override
  String toString() => 'SetManagerRequest[commandId=$commandId, expectedAccessVersion=$expectedAccessVersion, managerId=$managerId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.commandId != null) {
      json[r'commandId'] = this.commandId;
    } else {
      json[r'commandId'] = null;
    }
    if (this.expectedAccessVersion != null) {
      json[r'expectedAccessVersion'] = this.expectedAccessVersion;
    } else {
      json[r'expectedAccessVersion'] = null;
    }
    if (this.managerId != null) {
      json[r'managerId'] = this.managerId;
    } else {
      json[r'managerId'] = null;
    }
    return json;
  }

  /// Clones this instance of [SetManagerRequest] and returns a new one where some of the
  /// properties have changed.
  SetManagerRequest copyWith({
    String? commandId,
    bool commandIdSetToNull = false,
    int? expectedAccessVersion,
    bool expectedAccessVersionSetToNull = false,
    String? managerId,
    bool managerIdSetToNull = false,
  }) => SetManagerRequest(
    commandId: commandIdSetToNull ? null : commandId ?? this.commandId,
    expectedAccessVersion: expectedAccessVersionSetToNull ? null : expectedAccessVersion ?? this.expectedAccessVersion,
    managerId: managerIdSetToNull ? null : managerId ?? this.managerId,
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
        return true;
      }());

      return SetManagerRequest(
        commandId: mapValueOfType<String>(json, r'commandId'),
        expectedAccessVersion: mapValueOfType<int>(json, r'expectedAccessVersion'),
        managerId: mapValueOfType<String>(json, r'managerId'),
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
