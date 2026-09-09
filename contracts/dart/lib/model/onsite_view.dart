//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OnsiteView {
  /// Returns a new [OnsiteView] instance.
  OnsiteView({
    required this.employeeId,
    required this.from,
    required this.id,
    required this.location,
    required this.readAt,
    required this.reason,
    required this.reference,
    required this.revision,
    required this.state,
    required this.to,
    required this.version,
  });

  final String employeeId;

  final DateTime from;

  final String id;

  final String location;

  final DateTime? readAt;

  final String reason;

  final String reference;

  final int revision;

  final OnsiteState state;

  final DateTime to;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OnsiteView &&
    other.employeeId == employeeId &&
    other.from == from &&
    other.id == id &&
    other.location == location &&
    other.readAt == readAt &&
    other.reason == reason &&
    other.reference == reference &&
    other.revision == revision &&
    other.state == state &&
    other.to == to &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (employeeId.hashCode) +
    (from.hashCode) +
    (id.hashCode) +
    (location.hashCode) +
    (readAt == null ? 0 : readAt!.hashCode) +
    (reason.hashCode) +
    (reference.hashCode) +
    (revision.hashCode) +
    (state.hashCode) +
    (to.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'OnsiteView[employeeId=$employeeId, from=$from, id=$id, location=$location, readAt=$readAt, reason=$reason, reference=$reference, revision=$revision, state=$state, to=$to, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'employeeId'] = this.employeeId;
      json[r'from'] = _dateFormatter.format(this.from);
      json[r'id'] = this.id;
      json[r'location'] = this.location;
    if (this.readAt != null) {
      json[r'readAt'] = this.readAt!.toUtc().toIso8601String();
    } else {
      json[r'readAt'] = null;
    }
      json[r'reason'] = this.reason;
      json[r'reference'] = this.reference;
      json[r'revision'] = this.revision;
      json[r'state'] = this.state;
      json[r'to'] = _dateFormatter.format(this.to);
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [OnsiteView] and returns a new one where some of the
  /// properties have changed.
  OnsiteView copyWith({
    String? employeeId,
    DateTime? from,
    String? id,
    String? location,
    DateTime? readAt,
    bool readAtSetToNull = false,
    String? reason,
    String? reference,
    int? revision,
    OnsiteState? state,
    DateTime? to,
    int? version,
  }) => OnsiteView(
    employeeId: employeeId ?? this.employeeId,
    from: from ?? this.from,
    id: id ?? this.id,
    location: location ?? this.location,
    readAt: readAtSetToNull ? null : readAt ?? this.readAt,
    reason: reason ?? this.reason,
    reference: reference ?? this.reference,
    revision: revision ?? this.revision,
    state: state ?? this.state,
    to: to ?? this.to,
    version: version ?? this.version,
  );

  /// Returns a new [OnsiteView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OnsiteView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'employeeId'), 'Required key "OnsiteView[employeeId]" is missing from JSON.');
        assert(json[r'employeeId'] != null, 'Required key "OnsiteView[employeeId]" has a null value in JSON.');
        assert(json.containsKey(r'from'), 'Required key "OnsiteView[from]" is missing from JSON.');
        assert(json[r'from'] != null, 'Required key "OnsiteView[from]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "OnsiteView[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "OnsiteView[id]" has a null value in JSON.');
        assert(json.containsKey(r'location'), 'Required key "OnsiteView[location]" is missing from JSON.');
        assert(json[r'location'] != null, 'Required key "OnsiteView[location]" has a null value in JSON.');
        assert(json.containsKey(r'readAt'), 'Required key "OnsiteView[readAt]" is missing from JSON.');
        assert(json.containsKey(r'reason'), 'Required key "OnsiteView[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "OnsiteView[reason]" has a null value in JSON.');
        assert(json.containsKey(r'reference'), 'Required key "OnsiteView[reference]" is missing from JSON.');
        assert(json[r'reference'] != null, 'Required key "OnsiteView[reference]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "OnsiteView[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "OnsiteView[revision]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "OnsiteView[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "OnsiteView[state]" has a null value in JSON.');
        assert(json.containsKey(r'to'), 'Required key "OnsiteView[to]" is missing from JSON.');
        assert(json[r'to'] != null, 'Required key "OnsiteView[to]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "OnsiteView[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "OnsiteView[version]" has a null value in JSON.');
        return true;
      }());

      return OnsiteView(
        employeeId: mapValueOfType<String>(json, r'employeeId')!,
        from: mapDateTime(json, r'from', r'')!,
        id: mapValueOfType<String>(json, r'id')!,
        location: mapValueOfType<String>(json, r'location')!,
        readAt: mapDateTime(json, r'readAt', r''),
        reason: mapValueOfType<String>(json, r'reason')!,
        reference: mapValueOfType<String>(json, r'reference')!,
        revision: mapValueOfType<int>(json, r'revision')!,
        state: OnsiteState.fromJson(json[r'state'])!,
        to: mapDateTime(json, r'to', r'')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<OnsiteView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OnsiteView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OnsiteView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OnsiteView> mapFromJson(dynamic json) {
    final map = <String, OnsiteView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OnsiteView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OnsiteView-objects as value to a dart map
  static Map<String, List<OnsiteView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OnsiteView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OnsiteView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'employeeId',
    'from',
    'id',
    'location',
    'readAt',
    'reason',
    'reference',
    'revision',
    'state',
    'to',
    'version',
  };
}
