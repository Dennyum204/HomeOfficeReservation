//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProposalInput {
  /// Returns a new [ProposalInput] instance.
  ProposalInput({
    this.affectedDays = const [],
    this.days = const [],
    required this.expectedCalendarVersion,
    required this.expectedRequestVersion,
    required this.reason,
    this.requirementId,
    this.requirementRevision,
  });

  final List<SelectedDay> affectedDays;

  final List<DayInput> days;

  final int? expectedCalendarVersion;

  final int? expectedRequestVersion;

  final String reason;

  final String? requirementId;

  final int? requirementRevision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProposalInput &&
    _deepEquality.equals(other.affectedDays, affectedDays) &&
    _deepEquality.equals(other.days, days) &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.expectedRequestVersion == expectedRequestVersion &&
    other.reason == reason &&
    other.requirementId == requirementId &&
    other.requirementRevision == requirementRevision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (affectedDays.hashCode) +
    (days.hashCode) +
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (expectedRequestVersion == null ? 0 : expectedRequestVersion!.hashCode) +
    (reason.hashCode) +
    (requirementId == null ? 0 : requirementId!.hashCode) +
    (requirementRevision == null ? 0 : requirementRevision!.hashCode);

  @override
  String toString() => 'ProposalInput[affectedDays=$affectedDays, days=$days, expectedCalendarVersion=$expectedCalendarVersion, expectedRequestVersion=$expectedRequestVersion, reason=$reason, requirementId=$requirementId, requirementRevision=$requirementRevision]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'affectedDays'] = this.affectedDays;
      json[r'days'] = this.days;
    if (this.expectedCalendarVersion != null) {
      json[r'expectedCalendarVersion'] = this.expectedCalendarVersion;
    } else {
      json[r'expectedCalendarVersion'] = null;
    }
    if (this.expectedRequestVersion != null) {
      json[r'expectedRequestVersion'] = this.expectedRequestVersion;
    } else {
      json[r'expectedRequestVersion'] = null;
    }
      json[r'reason'] = this.reason;
    if (this.requirementId != null) {
      json[r'requirementId'] = this.requirementId;
    } else {
      json[r'requirementId'] = null;
    }
    if (this.requirementRevision != null) {
      json[r'requirementRevision'] = this.requirementRevision;
    } else {
      json[r'requirementRevision'] = null;
    }
    return json;
  }

  /// Clones this instance of [ProposalInput] and returns a new one where some of the
  /// properties have changed.
  ProposalInput copyWith({
    List<SelectedDay>? affectedDays,
    List<DayInput>? days,
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    int? expectedRequestVersion,
    bool expectedRequestVersionSetToNull = false,
    String? reason,
    String? requirementId,
    bool requirementIdSetToNull = false,
    int? requirementRevision,
    bool requirementRevisionSetToNull = false,
  }) => ProposalInput(
    affectedDays: affectedDays ?? this.affectedDays,
    days: days ?? this.days,
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    expectedRequestVersion: expectedRequestVersionSetToNull ? null : expectedRequestVersion ?? this.expectedRequestVersion,
    reason: reason ?? this.reason,
    requirementId: requirementIdSetToNull ? null : requirementId ?? this.requirementId,
    requirementRevision: requirementRevisionSetToNull ? null : requirementRevision ?? this.requirementRevision,
  );

  /// Returns a new [ProposalInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProposalInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'affectedDays'), 'Required key "ProposalInput[affectedDays]" is missing from JSON.');
        assert(json[r'affectedDays'] != null, 'Required key "ProposalInput[affectedDays]" has a null value in JSON.');
        assert(json.containsKey(r'days'), 'Required key "ProposalInput[days]" is missing from JSON.');
        assert(json[r'days'] != null, 'Required key "ProposalInput[days]" has a null value in JSON.');
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "ProposalInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'expectedRequestVersion'), 'Required key "ProposalInput[expectedRequestVersion]" is missing from JSON.');
        assert(json.containsKey(r'reason'), 'Required key "ProposalInput[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "ProposalInput[reason]" has a null value in JSON.');
        return true;
      }());

      return ProposalInput(
        affectedDays: SelectedDay.listFromJson(json[r'affectedDays']),
        days: DayInput.listFromJson(json[r'days']),
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        expectedRequestVersion: mapValueOfType<int>(json, r'expectedRequestVersion'),
        reason: mapValueOfType<String>(json, r'reason')!,
        requirementId: mapValueOfType<String>(json, r'requirementId'),
        requirementRevision: mapValueOfType<int>(json, r'requirementRevision'),
      );
    }
    return null;
  }

  static List<ProposalInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProposalInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProposalInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProposalInput> mapFromJson(dynamic json) {
    final map = <String, ProposalInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProposalInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProposalInput-objects as value to a dart map
  static Map<String, List<ProposalInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProposalInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProposalInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'affectedDays',
    'days',
    'expectedCalendarVersion',
    'expectedRequestVersion',
    'reason',
  };
}
