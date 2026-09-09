//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MemberProfile {
  /// Returns a new [MemberProfile] instance.
  MemberProfile({
    required this.active,
    required this.displayName,
    required this.email,
    required this.isAccountAdministrator,
    required this.isEmployee,
    required this.isManager,
    required this.memberId,
    required this.organizationId,
    required this.organizationName,
  });

  final bool active;

  final String displayName;

  final String email;

  final bool isAccountAdministrator;

  final bool isEmployee;

  final bool isManager;

  final String memberId;

  final String organizationId;

  final String organizationName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MemberProfile &&
    other.active == active &&
    other.displayName == displayName &&
    other.email == email &&
    other.isAccountAdministrator == isAccountAdministrator &&
    other.isEmployee == isEmployee &&
    other.isManager == isManager &&
    other.memberId == memberId &&
    other.organizationId == organizationId &&
    other.organizationName == organizationName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (active.hashCode) +
    (displayName.hashCode) +
    (email.hashCode) +
    (isAccountAdministrator.hashCode) +
    (isEmployee.hashCode) +
    (isManager.hashCode) +
    (memberId.hashCode) +
    (organizationId.hashCode) +
    (organizationName.hashCode);

  @override
  String toString() => 'MemberProfile[active=$active, displayName=$displayName, email=$email, isAccountAdministrator=$isAccountAdministrator, isEmployee=$isEmployee, isManager=$isManager, memberId=$memberId, organizationId=$organizationId, organizationName=$organizationName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'active'] = this.active;
      json[r'displayName'] = this.displayName;
      json[r'email'] = this.email;
      json[r'isAccountAdministrator'] = this.isAccountAdministrator;
      json[r'isEmployee'] = this.isEmployee;
      json[r'isManager'] = this.isManager;
      json[r'memberId'] = this.memberId;
      json[r'organizationId'] = this.organizationId;
      json[r'organizationName'] = this.organizationName;
    return json;
  }

  /// Clones this instance of [MemberProfile] and returns a new one where some of the
  /// properties have changed.
  MemberProfile copyWith({
    bool? active,
    String? displayName,
    String? email,
    bool? isAccountAdministrator,
    bool? isEmployee,
    bool? isManager,
    String? memberId,
    String? organizationId,
    String? organizationName,
  }) => MemberProfile(
    active: active ?? this.active,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    isAccountAdministrator: isAccountAdministrator ?? this.isAccountAdministrator,
    isEmployee: isEmployee ?? this.isEmployee,
    isManager: isManager ?? this.isManager,
    memberId: memberId ?? this.memberId,
    organizationId: organizationId ?? this.organizationId,
    organizationName: organizationName ?? this.organizationName,
  );

  /// Returns a new [MemberProfile] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MemberProfile? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'active'), 'Required key "MemberProfile[active]" is missing from JSON.');
        assert(json[r'active'] != null, 'Required key "MemberProfile[active]" has a null value in JSON.');
        assert(json.containsKey(r'displayName'), 'Required key "MemberProfile[displayName]" is missing from JSON.');
        assert(json[r'displayName'] != null, 'Required key "MemberProfile[displayName]" has a null value in JSON.');
        assert(json.containsKey(r'email'), 'Required key "MemberProfile[email]" is missing from JSON.');
        assert(json[r'email'] != null, 'Required key "MemberProfile[email]" has a null value in JSON.');
        assert(json.containsKey(r'isAccountAdministrator'), 'Required key "MemberProfile[isAccountAdministrator]" is missing from JSON.');
        assert(json[r'isAccountAdministrator'] != null, 'Required key "MemberProfile[isAccountAdministrator]" has a null value in JSON.');
        assert(json.containsKey(r'isEmployee'), 'Required key "MemberProfile[isEmployee]" is missing from JSON.');
        assert(json[r'isEmployee'] != null, 'Required key "MemberProfile[isEmployee]" has a null value in JSON.');
        assert(json.containsKey(r'isManager'), 'Required key "MemberProfile[isManager]" is missing from JSON.');
        assert(json[r'isManager'] != null, 'Required key "MemberProfile[isManager]" has a null value in JSON.');
        assert(json.containsKey(r'memberId'), 'Required key "MemberProfile[memberId]" is missing from JSON.');
        assert(json[r'memberId'] != null, 'Required key "MemberProfile[memberId]" has a null value in JSON.');
        assert(json.containsKey(r'organizationId'), 'Required key "MemberProfile[organizationId]" is missing from JSON.');
        assert(json[r'organizationId'] != null, 'Required key "MemberProfile[organizationId]" has a null value in JSON.');
        assert(json.containsKey(r'organizationName'), 'Required key "MemberProfile[organizationName]" is missing from JSON.');
        assert(json[r'organizationName'] != null, 'Required key "MemberProfile[organizationName]" has a null value in JSON.');
        return true;
      }());

      return MemberProfile(
        active: mapValueOfType<bool>(json, r'active')!,
        displayName: mapValueOfType<String>(json, r'displayName')!,
        email: mapValueOfType<String>(json, r'email')!,
        isAccountAdministrator: mapValueOfType<bool>(json, r'isAccountAdministrator')!,
        isEmployee: mapValueOfType<bool>(json, r'isEmployee')!,
        isManager: mapValueOfType<bool>(json, r'isManager')!,
        memberId: mapValueOfType<String>(json, r'memberId')!,
        organizationId: mapValueOfType<String>(json, r'organizationId')!,
        organizationName: mapValueOfType<String>(json, r'organizationName')!,
      );
    }
    return null;
  }

  static List<MemberProfile> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MemberProfile>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MemberProfile.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MemberProfile> mapFromJson(dynamic json) {
    final map = <String, MemberProfile>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MemberProfile.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MemberProfile-objects as value to a dart map
  static Map<String, List<MemberProfile>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MemberProfile>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MemberProfile.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'active',
    'displayName',
    'email',
    'isAccountAdministrator',
    'isEmployee',
    'isManager',
    'memberId',
    'organizationId',
    'organizationName',
  };
}
