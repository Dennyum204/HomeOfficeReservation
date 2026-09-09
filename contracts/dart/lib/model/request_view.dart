//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RequestView {
  /// Returns a new [RequestView] instance.
  RequestView({
    required this.acceptedProposalId,
    required this.createdAt,
    this.days = const [],
    required this.employeeId,
    required this.id,
    required this.note,
    required this.parentRevisionId,
    required this.revision,
    required this.rootId,
    required this.state,
    required this.submittedAt,
    required this.version,
  });

  final String? acceptedProposalId;

  final DateTime createdAt;

  final List<RequestedDayView> days;

  final String employeeId;

  final String id;

  final String note;

  final String? parentRevisionId;

  final int revision;

  final String rootId;

  final RequestState state;

  final DateTime? submittedAt;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RequestView &&
    other.acceptedProposalId == acceptedProposalId &&
    other.createdAt == createdAt &&
    _deepEquality.equals(other.days, days) &&
    other.employeeId == employeeId &&
    other.id == id &&
    other.note == note &&
    other.parentRevisionId == parentRevisionId &&
    other.revision == revision &&
    other.rootId == rootId &&
    other.state == state &&
    other.submittedAt == submittedAt &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (acceptedProposalId == null ? 0 : acceptedProposalId!.hashCode) +
    (createdAt.hashCode) +
    (days.hashCode) +
    (employeeId.hashCode) +
    (id.hashCode) +
    (note.hashCode) +
    (parentRevisionId == null ? 0 : parentRevisionId!.hashCode) +
    (revision.hashCode) +
    (rootId.hashCode) +
    (state.hashCode) +
    (submittedAt == null ? 0 : submittedAt!.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'RequestView[acceptedProposalId=$acceptedProposalId, createdAt=$createdAt, days=$days, employeeId=$employeeId, id=$id, note=$note, parentRevisionId=$parentRevisionId, revision=$revision, rootId=$rootId, state=$state, submittedAt=$submittedAt, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.acceptedProposalId != null) {
      json[r'acceptedProposalId'] = this.acceptedProposalId;
    } else {
      json[r'acceptedProposalId'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'days'] = this.days;
      json[r'employeeId'] = this.employeeId;
      json[r'id'] = this.id;
      json[r'note'] = this.note;
    if (this.parentRevisionId != null) {
      json[r'parentRevisionId'] = this.parentRevisionId;
    } else {
      json[r'parentRevisionId'] = null;
    }
      json[r'revision'] = this.revision;
      json[r'rootId'] = this.rootId;
      json[r'state'] = this.state;
    if (this.submittedAt != null) {
      json[r'submittedAt'] = this.submittedAt!.toUtc().toIso8601String();
    } else {
      json[r'submittedAt'] = null;
    }
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [RequestView] and returns a new one where some of the
  /// properties have changed.
  RequestView copyWith({
    String? acceptedProposalId,
    bool acceptedProposalIdSetToNull = false,
    DateTime? createdAt,
    List<RequestedDayView>? days,
    String? employeeId,
    String? id,
    String? note,
    String? parentRevisionId,
    bool parentRevisionIdSetToNull = false,
    int? revision,
    String? rootId,
    RequestState? state,
    DateTime? submittedAt,
    bool submittedAtSetToNull = false,
    int? version,
  }) => RequestView(
    acceptedProposalId: acceptedProposalIdSetToNull ? null : acceptedProposalId ?? this.acceptedProposalId,
    createdAt: createdAt ?? this.createdAt,
    days: days ?? this.days,
    employeeId: employeeId ?? this.employeeId,
    id: id ?? this.id,
    note: note ?? this.note,
    parentRevisionId: parentRevisionIdSetToNull ? null : parentRevisionId ?? this.parentRevisionId,
    revision: revision ?? this.revision,
    rootId: rootId ?? this.rootId,
    state: state ?? this.state,
    submittedAt: submittedAtSetToNull ? null : submittedAt ?? this.submittedAt,
    version: version ?? this.version,
  );

  /// Returns a new [RequestView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RequestView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'acceptedProposalId'), 'Required key "RequestView[acceptedProposalId]" is missing from JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "RequestView[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "RequestView[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'days'), 'Required key "RequestView[days]" is missing from JSON.');
        assert(json[r'days'] != null, 'Required key "RequestView[days]" has a null value in JSON.');
        assert(json.containsKey(r'employeeId'), 'Required key "RequestView[employeeId]" is missing from JSON.');
        assert(json[r'employeeId'] != null, 'Required key "RequestView[employeeId]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "RequestView[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "RequestView[id]" has a null value in JSON.');
        assert(json.containsKey(r'note'), 'Required key "RequestView[note]" is missing from JSON.');
        assert(json[r'note'] != null, 'Required key "RequestView[note]" has a null value in JSON.');
        assert(json.containsKey(r'parentRevisionId'), 'Required key "RequestView[parentRevisionId]" is missing from JSON.');
        assert(json.containsKey(r'revision'), 'Required key "RequestView[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "RequestView[revision]" has a null value in JSON.');
        assert(json.containsKey(r'rootId'), 'Required key "RequestView[rootId]" is missing from JSON.');
        assert(json[r'rootId'] != null, 'Required key "RequestView[rootId]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "RequestView[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "RequestView[state]" has a null value in JSON.');
        assert(json.containsKey(r'submittedAt'), 'Required key "RequestView[submittedAt]" is missing from JSON.');
        assert(json.containsKey(r'version'), 'Required key "RequestView[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "RequestView[version]" has a null value in JSON.');
        return true;
      }());

      return RequestView(
        acceptedProposalId: mapValueOfType<String>(json, r'acceptedProposalId'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        days: RequestedDayView.listFromJson(json[r'days']),
        employeeId: mapValueOfType<String>(json, r'employeeId')!,
        id: mapValueOfType<String>(json, r'id')!,
        note: mapValueOfType<String>(json, r'note')!,
        parentRevisionId: mapValueOfType<String>(json, r'parentRevisionId'),
        revision: mapValueOfType<int>(json, r'revision')!,
        rootId: mapValueOfType<String>(json, r'rootId')!,
        state: RequestState.fromJson(json[r'state'])!,
        submittedAt: mapDateTime(json, r'submittedAt', r''),
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<RequestView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RequestView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RequestView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RequestView> mapFromJson(dynamic json) {
    final map = <String, RequestView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RequestView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RequestView-objects as value to a dart map
  static Map<String, List<RequestView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RequestView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RequestView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'acceptedProposalId',
    'createdAt',
    'days',
    'employeeId',
    'id',
    'note',
    'parentRevisionId',
    'revision',
    'rootId',
    'state',
    'submittedAt',
    'version',
  };
}
