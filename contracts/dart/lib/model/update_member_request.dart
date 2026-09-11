//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateMemberRequest {
  /// Returns a new [UpdateMemberRequest] instance.
  UpdateMemberRequest({
    required this.active,
    this.commandId,
    this.expectedAccessVersion,
    required this.isAccountAdministrator,
    required this.isEmployee,
    required this.isManager,
  });

  final bool active;

  final String? commandId;

  final int? expectedAccessVersion;

  final bool isAccountAdministrator;

  final bool isEmployee;

  final bool isManager;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateMemberRequest &&
    other.active == active &&
    other.commandId == commandId &&
    other.expectedAccessVersion == expectedAccessVersion &&
    other.isAccountAdministrator == isAccountAdministrator &&
    other.isEmployee == isEmployee &&
    other.isManager == isManager;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (active.hashCode) +
    (commandId == null ? 0 : commandId!.hashCode) +
    (expectedAccessVersion == null ? 0 : expectedAccessVersion!.hashCode) +
    (isAccountAdministrator.hashCode) +
    (isEmployee.hashCode) +
    (isManager.hashCode);

  @override
  String toString() => 'UpdateMemberRequest[active=$active, commandId=$commandId, expectedAccessVersion=$expectedAccessVersion, isAccountAdministrator=$isAccountAdministrator, isEmployee=$isEmployee, isManager=$isManager]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'active'] = this.active;
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
      json[r'isAccountAdministrator'] = this.isAccountAdministrator;
      json[r'isEmployee'] = this.isEmployee;
      json[r'isManager'] = this.isManager;
    return json;
  }

  /// Clones this instance of [UpdateMemberRequest] and returns a new one where some of the
  /// properties have changed.
  UpdateMemberRequest copyWith({
    bool? active,
    String? commandId,
    bool commandIdSetToNull = false,
    int? expectedAccessVersion,
    bool expectedAccessVersionSetToNull = false,
    bool? isAccountAdministrator,
    bool? isEmployee,
    bool? isManager,
  }) => UpdateMemberRequest(
    active: active ?? this.active,
    commandId: commandIdSetToNull ? null : commandId ?? this.commandId,
    expectedAccessVersion: expectedAccessVersionSetToNull ? null : expectedAccessVersion ?? this.expectedAccessVersion,
    isAccountAdministrator: isAccountAdministrator ?? this.isAccountAdministrator,
    isEmployee: isEmployee ?? this.isEmployee,
    isManager: isManager ?? this.isManager,
  );

  /// Returns a new [UpdateMemberRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateMemberRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'active'), 'Required key "UpdateMemberRequest[active]" is missing from JSON.');
        assert(json[r'active'] != null, 'Required key "UpdateMemberRequest[active]" has a null value in JSON.');
        assert(json.containsKey(r'isAccountAdministrator'), 'Required key "UpdateMemberRequest[isAccountAdministrator]" is missing from JSON.');
        assert(json[r'isAccountAdministrator'] != null, 'Required key "UpdateMemberRequest[isAccountAdministrator]" has a null value in JSON.');
        assert(json.containsKey(r'isEmployee'), 'Required key "UpdateMemberRequest[isEmployee]" is missing from JSON.');
        assert(json[r'isEmployee'] != null, 'Required key "UpdateMemberRequest[isEmployee]" has a null value in JSON.');
        assert(json.containsKey(r'isManager'), 'Required key "UpdateMemberRequest[isManager]" is missing from JSON.');
        assert(json[r'isManager'] != null, 'Required key "UpdateMemberRequest[isManager]" has a null value in JSON.');
        return true;
      }());

      return UpdateMemberRequest(
        active: mapValueOfType<bool>(json, r'active')!,
        commandId: mapValueOfType<String>(json, r'commandId'),
        expectedAccessVersion: mapValueOfType<int>(json, r'expectedAccessVersion'),
        isAccountAdministrator: mapValueOfType<bool>(json, r'isAccountAdministrator')!,
        isEmployee: mapValueOfType<bool>(json, r'isEmployee')!,
        isManager: mapValueOfType<bool>(json, r'isManager')!,
      );
    }
    return null;
  }

  static List<UpdateMemberRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateMemberRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateMemberRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateMemberRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateMemberRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateMemberRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateMemberRequest-objects as value to a dart map
  static Map<String, List<UpdateMemberRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateMemberRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateMemberRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'active',
    'isAccountAdministrator',
    'isEmployee',
    'isManager',
  };
}
