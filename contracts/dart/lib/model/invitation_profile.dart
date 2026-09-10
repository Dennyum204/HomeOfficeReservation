//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InvitationProfile {
  /// Returns a new [InvitationProfile] instance.
  InvitationProfile({
    required this.acceptedAt,
    required this.active,
    required this.cancelledAt,
    required this.codeExpiresAt,
    required this.deliveredAt,
    required this.deliveryAttempts,
    required this.deliveryError,
    required this.deliveryState,
    required this.displayName,
    required this.email,
    required this.emailConfirmed,
    required this.isAccountAdministrator,
    required this.isEmployee,
    required this.isManager,
    required this.managerId,
    required this.managerRelationshipValid,
    required this.memberId,
    required this.resendAvailableAt,
    required this.state,
    required this.version,
  });

  final DateTime? acceptedAt;

  final bool active;

  final DateTime? cancelledAt;

  final DateTime? codeExpiresAt;

  final DateTime? deliveredAt;

  final int deliveryAttempts;

  final String? deliveryError;

  final String deliveryState;

  final String displayName;

  final String email;

  final bool emailConfirmed;

  final bool isAccountAdministrator;

  final bool isEmployee;

  final bool isManager;

  final String? managerId;

  final bool managerRelationshipValid;

  final String memberId;

  final DateTime? resendAvailableAt;

  final String state;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InvitationProfile &&
    other.acceptedAt == acceptedAt &&
    other.active == active &&
    other.cancelledAt == cancelledAt &&
    other.codeExpiresAt == codeExpiresAt &&
    other.deliveredAt == deliveredAt &&
    other.deliveryAttempts == deliveryAttempts &&
    other.deliveryError == deliveryError &&
    other.deliveryState == deliveryState &&
    other.displayName == displayName &&
    other.email == email &&
    other.emailConfirmed == emailConfirmed &&
    other.isAccountAdministrator == isAccountAdministrator &&
    other.isEmployee == isEmployee &&
    other.isManager == isManager &&
    other.managerId == managerId &&
    other.managerRelationshipValid == managerRelationshipValid &&
    other.memberId == memberId &&
    other.resendAvailableAt == resendAvailableAt &&
    other.state == state &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (acceptedAt == null ? 0 : acceptedAt!.hashCode) +
    (active.hashCode) +
    (cancelledAt == null ? 0 : cancelledAt!.hashCode) +
    (codeExpiresAt == null ? 0 : codeExpiresAt!.hashCode) +
    (deliveredAt == null ? 0 : deliveredAt!.hashCode) +
    (deliveryAttempts.hashCode) +
    (deliveryError == null ? 0 : deliveryError!.hashCode) +
    (deliveryState.hashCode) +
    (displayName.hashCode) +
    (email.hashCode) +
    (emailConfirmed.hashCode) +
    (isAccountAdministrator.hashCode) +
    (isEmployee.hashCode) +
    (isManager.hashCode) +
    (managerId == null ? 0 : managerId!.hashCode) +
    (managerRelationshipValid.hashCode) +
    (memberId.hashCode) +
    (resendAvailableAt == null ? 0 : resendAvailableAt!.hashCode) +
    (state.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'InvitationProfile[acceptedAt=$acceptedAt, active=$active, cancelledAt=$cancelledAt, codeExpiresAt=$codeExpiresAt, deliveredAt=$deliveredAt, deliveryAttempts=$deliveryAttempts, deliveryError=$deliveryError, deliveryState=$deliveryState, displayName=$displayName, email=$email, emailConfirmed=$emailConfirmed, isAccountAdministrator=$isAccountAdministrator, isEmployee=$isEmployee, isManager=$isManager, managerId=$managerId, managerRelationshipValid=$managerRelationshipValid, memberId=$memberId, resendAvailableAt=$resendAvailableAt, state=$state, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.acceptedAt != null) {
      json[r'acceptedAt'] = this.acceptedAt!.toUtc().toIso8601String();
    } else {
      json[r'acceptedAt'] = null;
    }
      json[r'active'] = this.active;
    if (this.cancelledAt != null) {
      json[r'cancelledAt'] = this.cancelledAt!.toUtc().toIso8601String();
    } else {
      json[r'cancelledAt'] = null;
    }
    if (this.codeExpiresAt != null) {
      json[r'codeExpiresAt'] = this.codeExpiresAt!.toUtc().toIso8601String();
    } else {
      json[r'codeExpiresAt'] = null;
    }
    if (this.deliveredAt != null) {
      json[r'deliveredAt'] = this.deliveredAt!.toUtc().toIso8601String();
    } else {
      json[r'deliveredAt'] = null;
    }
      json[r'deliveryAttempts'] = this.deliveryAttempts;
    if (this.deliveryError != null) {
      json[r'deliveryError'] = this.deliveryError;
    } else {
      json[r'deliveryError'] = null;
    }
      json[r'deliveryState'] = this.deliveryState;
      json[r'displayName'] = this.displayName;
      json[r'email'] = this.email;
      json[r'emailConfirmed'] = this.emailConfirmed;
      json[r'isAccountAdministrator'] = this.isAccountAdministrator;
      json[r'isEmployee'] = this.isEmployee;
      json[r'isManager'] = this.isManager;
    if (this.managerId != null) {
      json[r'managerId'] = this.managerId;
    } else {
      json[r'managerId'] = null;
    }
      json[r'managerRelationshipValid'] = this.managerRelationshipValid;
      json[r'memberId'] = this.memberId;
    if (this.resendAvailableAt != null) {
      json[r'resendAvailableAt'] = this.resendAvailableAt!.toUtc().toIso8601String();
    } else {
      json[r'resendAvailableAt'] = null;
    }
      json[r'state'] = this.state;
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [InvitationProfile] and returns a new one where some of the
  /// properties have changed.
  InvitationProfile copyWith({
    DateTime? acceptedAt,
    bool acceptedAtSetToNull = false,
    bool? active,
    DateTime? cancelledAt,
    bool cancelledAtSetToNull = false,
    DateTime? codeExpiresAt,
    bool codeExpiresAtSetToNull = false,
    DateTime? deliveredAt,
    bool deliveredAtSetToNull = false,
    int? deliveryAttempts,
    String? deliveryError,
    bool deliveryErrorSetToNull = false,
    String? deliveryState,
    String? displayName,
    String? email,
    bool? emailConfirmed,
    bool? isAccountAdministrator,
    bool? isEmployee,
    bool? isManager,
    String? managerId,
    bool managerIdSetToNull = false,
    bool? managerRelationshipValid,
    String? memberId,
    DateTime? resendAvailableAt,
    bool resendAvailableAtSetToNull = false,
    String? state,
    int? version,
  }) => InvitationProfile(
    acceptedAt: acceptedAtSetToNull ? null : acceptedAt ?? this.acceptedAt,
    active: active ?? this.active,
    cancelledAt: cancelledAtSetToNull ? null : cancelledAt ?? this.cancelledAt,
    codeExpiresAt: codeExpiresAtSetToNull ? null : codeExpiresAt ?? this.codeExpiresAt,
    deliveredAt: deliveredAtSetToNull ? null : deliveredAt ?? this.deliveredAt,
    deliveryAttempts: deliveryAttempts ?? this.deliveryAttempts,
    deliveryError: deliveryErrorSetToNull ? null : deliveryError ?? this.deliveryError,
    deliveryState: deliveryState ?? this.deliveryState,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    emailConfirmed: emailConfirmed ?? this.emailConfirmed,
    isAccountAdministrator: isAccountAdministrator ?? this.isAccountAdministrator,
    isEmployee: isEmployee ?? this.isEmployee,
    isManager: isManager ?? this.isManager,
    managerId: managerIdSetToNull ? null : managerId ?? this.managerId,
    managerRelationshipValid: managerRelationshipValid ?? this.managerRelationshipValid,
    memberId: memberId ?? this.memberId,
    resendAvailableAt: resendAvailableAtSetToNull ? null : resendAvailableAt ?? this.resendAvailableAt,
    state: state ?? this.state,
    version: version ?? this.version,
  );

  /// Returns a new [InvitationProfile] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InvitationProfile? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'acceptedAt'), 'Required key "InvitationProfile[acceptedAt]" is missing from JSON.');
        assert(json.containsKey(r'active'), 'Required key "InvitationProfile[active]" is missing from JSON.');
        assert(json[r'active'] != null, 'Required key "InvitationProfile[active]" has a null value in JSON.');
        assert(json.containsKey(r'cancelledAt'), 'Required key "InvitationProfile[cancelledAt]" is missing from JSON.');
        assert(json.containsKey(r'codeExpiresAt'), 'Required key "InvitationProfile[codeExpiresAt]" is missing from JSON.');
        assert(json.containsKey(r'deliveredAt'), 'Required key "InvitationProfile[deliveredAt]" is missing from JSON.');
        assert(json.containsKey(r'deliveryAttempts'), 'Required key "InvitationProfile[deliveryAttempts]" is missing from JSON.');
        assert(json[r'deliveryAttempts'] != null, 'Required key "InvitationProfile[deliveryAttempts]" has a null value in JSON.');
        assert(json.containsKey(r'deliveryError'), 'Required key "InvitationProfile[deliveryError]" is missing from JSON.');
        assert(json.containsKey(r'deliveryState'), 'Required key "InvitationProfile[deliveryState]" is missing from JSON.');
        assert(json[r'deliveryState'] != null, 'Required key "InvitationProfile[deliveryState]" has a null value in JSON.');
        assert(json.containsKey(r'displayName'), 'Required key "InvitationProfile[displayName]" is missing from JSON.');
        assert(json[r'displayName'] != null, 'Required key "InvitationProfile[displayName]" has a null value in JSON.');
        assert(json.containsKey(r'email'), 'Required key "InvitationProfile[email]" is missing from JSON.');
        assert(json[r'email'] != null, 'Required key "InvitationProfile[email]" has a null value in JSON.');
        assert(json.containsKey(r'emailConfirmed'), 'Required key "InvitationProfile[emailConfirmed]" is missing from JSON.');
        assert(json[r'emailConfirmed'] != null, 'Required key "InvitationProfile[emailConfirmed]" has a null value in JSON.');
        assert(json.containsKey(r'isAccountAdministrator'), 'Required key "InvitationProfile[isAccountAdministrator]" is missing from JSON.');
        assert(json[r'isAccountAdministrator'] != null, 'Required key "InvitationProfile[isAccountAdministrator]" has a null value in JSON.');
        assert(json.containsKey(r'isEmployee'), 'Required key "InvitationProfile[isEmployee]" is missing from JSON.');
        assert(json[r'isEmployee'] != null, 'Required key "InvitationProfile[isEmployee]" has a null value in JSON.');
        assert(json.containsKey(r'isManager'), 'Required key "InvitationProfile[isManager]" is missing from JSON.');
        assert(json[r'isManager'] != null, 'Required key "InvitationProfile[isManager]" has a null value in JSON.');
        assert(json.containsKey(r'managerId'), 'Required key "InvitationProfile[managerId]" is missing from JSON.');
        assert(json.containsKey(r'managerRelationshipValid'), 'Required key "InvitationProfile[managerRelationshipValid]" is missing from JSON.');
        assert(json[r'managerRelationshipValid'] != null, 'Required key "InvitationProfile[managerRelationshipValid]" has a null value in JSON.');
        assert(json.containsKey(r'memberId'), 'Required key "InvitationProfile[memberId]" is missing from JSON.');
        assert(json[r'memberId'] != null, 'Required key "InvitationProfile[memberId]" has a null value in JSON.');
        assert(json.containsKey(r'resendAvailableAt'), 'Required key "InvitationProfile[resendAvailableAt]" is missing from JSON.');
        assert(json.containsKey(r'state'), 'Required key "InvitationProfile[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "InvitationProfile[state]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "InvitationProfile[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "InvitationProfile[version]" has a null value in JSON.');
        return true;
      }());

      return InvitationProfile(
        acceptedAt: mapDateTime(json, r'acceptedAt', r''),
        active: mapValueOfType<bool>(json, r'active')!,
        cancelledAt: mapDateTime(json, r'cancelledAt', r''),
        codeExpiresAt: mapDateTime(json, r'codeExpiresAt', r''),
        deliveredAt: mapDateTime(json, r'deliveredAt', r''),
        deliveryAttempts: mapValueOfType<int>(json, r'deliveryAttempts')!,
        deliveryError: mapValueOfType<String>(json, r'deliveryError'),
        deliveryState: mapValueOfType<String>(json, r'deliveryState')!,
        displayName: mapValueOfType<String>(json, r'displayName')!,
        email: mapValueOfType<String>(json, r'email')!,
        emailConfirmed: mapValueOfType<bool>(json, r'emailConfirmed')!,
        isAccountAdministrator: mapValueOfType<bool>(json, r'isAccountAdministrator')!,
        isEmployee: mapValueOfType<bool>(json, r'isEmployee')!,
        isManager: mapValueOfType<bool>(json, r'isManager')!,
        managerId: mapValueOfType<String>(json, r'managerId'),
        managerRelationshipValid: mapValueOfType<bool>(json, r'managerRelationshipValid')!,
        memberId: mapValueOfType<String>(json, r'memberId')!,
        resendAvailableAt: mapDateTime(json, r'resendAvailableAt', r''),
        state: mapValueOfType<String>(json, r'state')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<InvitationProfile> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InvitationProfile>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InvitationProfile.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InvitationProfile> mapFromJson(dynamic json) {
    final map = <String, InvitationProfile>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InvitationProfile.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InvitationProfile-objects as value to a dart map
  static Map<String, List<InvitationProfile>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InvitationProfile>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InvitationProfile.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'acceptedAt',
    'active',
    'cancelledAt',
    'codeExpiresAt',
    'deliveredAt',
    'deliveryAttempts',
    'deliveryError',
    'deliveryState',
    'displayName',
    'email',
    'emailConfirmed',
    'isAccountAdministrator',
    'isEmployee',
    'isManager',
    'managerId',
    'managerRelationshipValid',
    'memberId',
    'resendAvailableAt',
    'state',
    'version',
  };
}
