//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProvisionMemberRequest {
  /// Returns a new [ProvisionMemberRequest] instance.
  ProvisionMemberRequest({
    required this.displayName,
    required this.email,
    required this.isAccountAdministrator,
    required this.isEmployee,
    required this.isManager,
  });

  final String displayName;

  final String email;

  final bool isAccountAdministrator;

  final bool isEmployee;

  final bool isManager;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProvisionMemberRequest &&
    other.displayName == displayName &&
    other.email == email &&
    other.isAccountAdministrator == isAccountAdministrator &&
    other.isEmployee == isEmployee &&
    other.isManager == isManager;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (displayName.hashCode) +
    (email.hashCode) +
    (isAccountAdministrator.hashCode) +
    (isEmployee.hashCode) +
    (isManager.hashCode);

  @override
  String toString() => 'ProvisionMemberRequest[displayName=$displayName, email=$email, isAccountAdministrator=$isAccountAdministrator, isEmployee=$isEmployee, isManager=$isManager]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'displayName'] = this.displayName;
      json[r'email'] = this.email;
      json[r'isAccountAdministrator'] = this.isAccountAdministrator;
      json[r'isEmployee'] = this.isEmployee;
      json[r'isManager'] = this.isManager;
    return json;
  }

  /// Clones this instance of [ProvisionMemberRequest] and returns a new one where some of the
  /// properties have changed.
  ProvisionMemberRequest copyWith({
    String? displayName,
    String? email,
    bool? isAccountAdministrator,
    bool? isEmployee,
    bool? isManager,
  }) => ProvisionMemberRequest(
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    isAccountAdministrator: isAccountAdministrator ?? this.isAccountAdministrator,
    isEmployee: isEmployee ?? this.isEmployee,
    isManager: isManager ?? this.isManager,
  );

  /// Returns a new [ProvisionMemberRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProvisionMemberRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'displayName'), 'Required key "ProvisionMemberRequest[displayName]" is missing from JSON.');
        assert(json[r'displayName'] != null, 'Required key "ProvisionMemberRequest[displayName]" has a null value in JSON.');
        assert(json.containsKey(r'email'), 'Required key "ProvisionMemberRequest[email]" is missing from JSON.');
        assert(json[r'email'] != null, 'Required key "ProvisionMemberRequest[email]" has a null value in JSON.');
        assert(json.containsKey(r'isAccountAdministrator'), 'Required key "ProvisionMemberRequest[isAccountAdministrator]" is missing from JSON.');
        assert(json[r'isAccountAdministrator'] != null, 'Required key "ProvisionMemberRequest[isAccountAdministrator]" has a null value in JSON.');
        assert(json.containsKey(r'isEmployee'), 'Required key "ProvisionMemberRequest[isEmployee]" is missing from JSON.');
        assert(json[r'isEmployee'] != null, 'Required key "ProvisionMemberRequest[isEmployee]" has a null value in JSON.');
        assert(json.containsKey(r'isManager'), 'Required key "ProvisionMemberRequest[isManager]" is missing from JSON.');
        assert(json[r'isManager'] != null, 'Required key "ProvisionMemberRequest[isManager]" has a null value in JSON.');
        return true;
      }());

      return ProvisionMemberRequest(
        displayName: mapValueOfType<String>(json, r'displayName')!,
        email: mapValueOfType<String>(json, r'email')!,
        isAccountAdministrator: mapValueOfType<bool>(json, r'isAccountAdministrator')!,
        isEmployee: mapValueOfType<bool>(json, r'isEmployee')!,
        isManager: mapValueOfType<bool>(json, r'isManager')!,
      );
    }
    return null;
  }

  static List<ProvisionMemberRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProvisionMemberRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProvisionMemberRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProvisionMemberRequest> mapFromJson(dynamic json) {
    final map = <String, ProvisionMemberRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProvisionMemberRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProvisionMemberRequest-objects as value to a dart map
  static Map<String, List<ProvisionMemberRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProvisionMemberRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProvisionMemberRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'displayName',
    'email',
    'isAccountAdministrator',
    'isEmployee',
    'isManager',
  };
}
