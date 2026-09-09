//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProposalView {
  /// Returns a new [ProposalView] instance.
  ProposalView({
    required this.acceptedRequestId,
    required this.acknowledgedAt,
    this.affectedDayIds = const [],
    required this.authorId,
    required this.createdAt,
    this.days = const [],
    required this.groupId,
    required this.id,
    required this.reason,
    required this.requestId,
    this.requirementId,
    this.requirementRevision,
    required this.revision,
    required this.state,
  });

  final String? acceptedRequestId;

  final DateTime? acknowledgedAt;

  final List<String> affectedDayIds;

  final String authorId;

  final DateTime createdAt;

  final List<DayInput> days;

  final String groupId;

  final String id;

  final String reason;

  final String requestId;

  final String? requirementId;

  final int? requirementRevision;

  final int revision;

  final ProposalState state;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProposalView &&
    other.acceptedRequestId == acceptedRequestId &&
    other.acknowledgedAt == acknowledgedAt &&
    _deepEquality.equals(other.affectedDayIds, affectedDayIds) &&
    other.authorId == authorId &&
    other.createdAt == createdAt &&
    _deepEquality.equals(other.days, days) &&
    other.groupId == groupId &&
    other.id == id &&
    other.reason == reason &&
    other.requestId == requestId &&
    other.requirementId == requirementId &&
    other.requirementRevision == requirementRevision &&
    other.revision == revision &&
    other.state == state;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (acceptedRequestId == null ? 0 : acceptedRequestId!.hashCode) +
    (acknowledgedAt == null ? 0 : acknowledgedAt!.hashCode) +
    (affectedDayIds.hashCode) +
    (authorId.hashCode) +
    (createdAt.hashCode) +
    (days.hashCode) +
    (groupId.hashCode) +
    (id.hashCode) +
    (reason.hashCode) +
    (requestId.hashCode) +
    (requirementId == null ? 0 : requirementId!.hashCode) +
    (requirementRevision == null ? 0 : requirementRevision!.hashCode) +
    (revision.hashCode) +
    (state.hashCode);

  @override
  String toString() => 'ProposalView[acceptedRequestId=$acceptedRequestId, acknowledgedAt=$acknowledgedAt, affectedDayIds=$affectedDayIds, authorId=$authorId, createdAt=$createdAt, days=$days, groupId=$groupId, id=$id, reason=$reason, requestId=$requestId, requirementId=$requirementId, requirementRevision=$requirementRevision, revision=$revision, state=$state]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.acceptedRequestId != null) {
      json[r'acceptedRequestId'] = this.acceptedRequestId;
    } else {
      json[r'acceptedRequestId'] = null;
    }
    if (this.acknowledgedAt != null) {
      json[r'acknowledgedAt'] = this.acknowledgedAt!.toUtc().toIso8601String();
    } else {
      json[r'acknowledgedAt'] = null;
    }
      json[r'affectedDayIds'] = this.affectedDayIds;
      json[r'authorId'] = this.authorId;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'days'] = this.days;
      json[r'groupId'] = this.groupId;
      json[r'id'] = this.id;
      json[r'reason'] = this.reason;
      json[r'requestId'] = this.requestId;
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
      json[r'revision'] = this.revision;
      json[r'state'] = this.state;
    return json;
  }

  /// Clones this instance of [ProposalView] and returns a new one where some of the
  /// properties have changed.
  ProposalView copyWith({
    String? acceptedRequestId,
    bool acceptedRequestIdSetToNull = false,
    DateTime? acknowledgedAt,
    bool acknowledgedAtSetToNull = false,
    List<String>? affectedDayIds,
    String? authorId,
    DateTime? createdAt,
    List<DayInput>? days,
    String? groupId,
    String? id,
    String? reason,
    String? requestId,
    String? requirementId,
    bool requirementIdSetToNull = false,
    int? requirementRevision,
    bool requirementRevisionSetToNull = false,
    int? revision,
    ProposalState? state,
  }) => ProposalView(
    acceptedRequestId: acceptedRequestIdSetToNull ? null : acceptedRequestId ?? this.acceptedRequestId,
    acknowledgedAt: acknowledgedAtSetToNull ? null : acknowledgedAt ?? this.acknowledgedAt,
    affectedDayIds: affectedDayIds ?? this.affectedDayIds,
    authorId: authorId ?? this.authorId,
    createdAt: createdAt ?? this.createdAt,
    days: days ?? this.days,
    groupId: groupId ?? this.groupId,
    id: id ?? this.id,
    reason: reason ?? this.reason,
    requestId: requestId ?? this.requestId,
    requirementId: requirementIdSetToNull ? null : requirementId ?? this.requirementId,
    requirementRevision: requirementRevisionSetToNull ? null : requirementRevision ?? this.requirementRevision,
    revision: revision ?? this.revision,
    state: state ?? this.state,
  );

  /// Returns a new [ProposalView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProposalView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'acceptedRequestId'), 'Required key "ProposalView[acceptedRequestId]" is missing from JSON.');
        assert(json.containsKey(r'acknowledgedAt'), 'Required key "ProposalView[acknowledgedAt]" is missing from JSON.');
        assert(json.containsKey(r'affectedDayIds'), 'Required key "ProposalView[affectedDayIds]" is missing from JSON.');
        assert(json[r'affectedDayIds'] != null, 'Required key "ProposalView[affectedDayIds]" has a null value in JSON.');
        assert(json.containsKey(r'authorId'), 'Required key "ProposalView[authorId]" is missing from JSON.');
        assert(json[r'authorId'] != null, 'Required key "ProposalView[authorId]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "ProposalView[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ProposalView[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'days'), 'Required key "ProposalView[days]" is missing from JSON.');
        assert(json[r'days'] != null, 'Required key "ProposalView[days]" has a null value in JSON.');
        assert(json.containsKey(r'groupId'), 'Required key "ProposalView[groupId]" is missing from JSON.');
        assert(json[r'groupId'] != null, 'Required key "ProposalView[groupId]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "ProposalView[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ProposalView[id]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "ProposalView[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "ProposalView[reason]" has a null value in JSON.');
        assert(json.containsKey(r'requestId'), 'Required key "ProposalView[requestId]" is missing from JSON.');
        assert(json[r'requestId'] != null, 'Required key "ProposalView[requestId]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "ProposalView[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "ProposalView[revision]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "ProposalView[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "ProposalView[state]" has a null value in JSON.');
        return true;
      }());

      return ProposalView(
        acceptedRequestId: mapValueOfType<String>(json, r'acceptedRequestId'),
        acknowledgedAt: mapDateTime(json, r'acknowledgedAt', r''),
        affectedDayIds: json[r'affectedDayIds'] is Iterable
            ? (json[r'affectedDayIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        authorId: mapValueOfType<String>(json, r'authorId')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        days: DayInput.listFromJson(json[r'days']),
        groupId: mapValueOfType<String>(json, r'groupId')!,
        id: mapValueOfType<String>(json, r'id')!,
        reason: mapValueOfType<String>(json, r'reason')!,
        requestId: mapValueOfType<String>(json, r'requestId')!,
        requirementId: mapValueOfType<String>(json, r'requirementId'),
        requirementRevision: mapValueOfType<int>(json, r'requirementRevision'),
        revision: mapValueOfType<int>(json, r'revision')!,
        state: ProposalState.fromJson(json[r'state'])!,
      );
    }
    return null;
  }

  static List<ProposalView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProposalView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProposalView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProposalView> mapFromJson(dynamic json) {
    final map = <String, ProposalView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProposalView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProposalView-objects as value to a dart map
  static Map<String, List<ProposalView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProposalView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProposalView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'acceptedRequestId',
    'acknowledgedAt',
    'affectedDayIds',
    'authorId',
    'createdAt',
    'days',
    'groupId',
    'id',
    'reason',
    'requestId',
    'revision',
    'state',
  };
}
