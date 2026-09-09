//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RequestedDayView {
  /// Returns a new [RequestedDayView] instance.
  RequestedDayView({
    required this.availability,
    required this.baseDayId,
    required this.basePlanVersion,
    required this.cancel,
    required this.decidedAt,
    required this.decidedBy,
    required this.decision,
    required this.id,
    required this.localDate,
    required this.location,
    required this.reason,
    required this.version,
  });

  final Availability availability;

  final String? baseDayId;

  final int? basePlanVersion;

  final bool cancel;

  final DateTime? decidedAt;

  final String? decidedBy;

  final DayDecision decision;

  final String id;

  final DateTime localDate;

  final WorkLocation location;

  final String? reason;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RequestedDayView &&
    other.availability == availability &&
    other.baseDayId == baseDayId &&
    other.basePlanVersion == basePlanVersion &&
    other.cancel == cancel &&
    other.decidedAt == decidedAt &&
    other.decidedBy == decidedBy &&
    other.decision == decision &&
    other.id == id &&
    other.localDate == localDate &&
    other.location == location &&
    other.reason == reason &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (availability.hashCode) +
    (baseDayId == null ? 0 : baseDayId!.hashCode) +
    (basePlanVersion == null ? 0 : basePlanVersion!.hashCode) +
    (cancel.hashCode) +
    (decidedAt == null ? 0 : decidedAt!.hashCode) +
    (decidedBy == null ? 0 : decidedBy!.hashCode) +
    (decision.hashCode) +
    (id.hashCode) +
    (localDate.hashCode) +
    (location.hashCode) +
    (reason == null ? 0 : reason!.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'RequestedDayView[availability=$availability, baseDayId=$baseDayId, basePlanVersion=$basePlanVersion, cancel=$cancel, decidedAt=$decidedAt, decidedBy=$decidedBy, decision=$decision, id=$id, localDate=$localDate, location=$location, reason=$reason, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'availability'] = this.availability;
    if (this.baseDayId != null) {
      json[r'baseDayId'] = this.baseDayId;
    } else {
      json[r'baseDayId'] = null;
    }
    if (this.basePlanVersion != null) {
      json[r'basePlanVersion'] = this.basePlanVersion;
    } else {
      json[r'basePlanVersion'] = null;
    }
      json[r'cancel'] = this.cancel;
    if (this.decidedAt != null) {
      json[r'decidedAt'] = this.decidedAt!.toUtc().toIso8601String();
    } else {
      json[r'decidedAt'] = null;
    }
    if (this.decidedBy != null) {
      json[r'decidedBy'] = this.decidedBy;
    } else {
      json[r'decidedBy'] = null;
    }
      json[r'decision'] = this.decision;
      json[r'id'] = this.id;
      json[r'localDate'] = _dateFormatter.format(this.localDate);
      json[r'location'] = this.location;
    if (this.reason != null) {
      json[r'reason'] = this.reason;
    } else {
      json[r'reason'] = null;
    }
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [RequestedDayView] and returns a new one where some of the
  /// properties have changed.
  RequestedDayView copyWith({
    Availability? availability,
    String? baseDayId,
    bool baseDayIdSetToNull = false,
    int? basePlanVersion,
    bool basePlanVersionSetToNull = false,
    bool? cancel,
    DateTime? decidedAt,
    bool decidedAtSetToNull = false,
    String? decidedBy,
    bool decidedBySetToNull = false,
    DayDecision? decision,
    String? id,
    DateTime? localDate,
    WorkLocation? location,
    String? reason,
    bool reasonSetToNull = false,
    int? version,
  }) => RequestedDayView(
    availability: availability ?? this.availability,
    baseDayId: baseDayIdSetToNull ? null : baseDayId ?? this.baseDayId,
    basePlanVersion: basePlanVersionSetToNull ? null : basePlanVersion ?? this.basePlanVersion,
    cancel: cancel ?? this.cancel,
    decidedAt: decidedAtSetToNull ? null : decidedAt ?? this.decidedAt,
    decidedBy: decidedBySetToNull ? null : decidedBy ?? this.decidedBy,
    decision: decision ?? this.decision,
    id: id ?? this.id,
    localDate: localDate ?? this.localDate,
    location: location ?? this.location,
    reason: reasonSetToNull ? null : reason ?? this.reason,
    version: version ?? this.version,
  );

  /// Returns a new [RequestedDayView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RequestedDayView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'availability'), 'Required key "RequestedDayView[availability]" is missing from JSON.');
        assert(json[r'availability'] != null, 'Required key "RequestedDayView[availability]" has a null value in JSON.');
        assert(json.containsKey(r'baseDayId'), 'Required key "RequestedDayView[baseDayId]" is missing from JSON.');
        assert(json.containsKey(r'basePlanVersion'), 'Required key "RequestedDayView[basePlanVersion]" is missing from JSON.');
        assert(json.containsKey(r'cancel'), 'Required key "RequestedDayView[cancel]" is missing from JSON.');
        assert(json[r'cancel'] != null, 'Required key "RequestedDayView[cancel]" has a null value in JSON.');
        assert(json.containsKey(r'decidedAt'), 'Required key "RequestedDayView[decidedAt]" is missing from JSON.');
        assert(json.containsKey(r'decidedBy'), 'Required key "RequestedDayView[decidedBy]" is missing from JSON.');
        assert(json.containsKey(r'decision'), 'Required key "RequestedDayView[decision]" is missing from JSON.');
        assert(json[r'decision'] != null, 'Required key "RequestedDayView[decision]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "RequestedDayView[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "RequestedDayView[id]" has a null value in JSON.');
        assert(json.containsKey(r'localDate'), 'Required key "RequestedDayView[localDate]" is missing from JSON.');
        assert(json[r'localDate'] != null, 'Required key "RequestedDayView[localDate]" has a null value in JSON.');
        assert(json.containsKey(r'location'), 'Required key "RequestedDayView[location]" is missing from JSON.');
        assert(json[r'location'] != null, 'Required key "RequestedDayView[location]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "RequestedDayView[reason]" is missing from JSON.');
        assert(json.containsKey(r'version'), 'Required key "RequestedDayView[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "RequestedDayView[version]" has a null value in JSON.');
        return true;
      }());

      return RequestedDayView(
        availability: Availability.fromJson(json[r'availability'])!,
        baseDayId: mapValueOfType<String>(json, r'baseDayId'),
        basePlanVersion: mapValueOfType<int>(json, r'basePlanVersion'),
        cancel: mapValueOfType<bool>(json, r'cancel')!,
        decidedAt: mapDateTime(json, r'decidedAt', r''),
        decidedBy: mapValueOfType<String>(json, r'decidedBy'),
        decision: DayDecision.fromJson(json[r'decision'])!,
        id: mapValueOfType<String>(json, r'id')!,
        localDate: mapDateTime(json, r'localDate', r'')!,
        location: WorkLocation.fromJson(json[r'location'])!,
        reason: mapValueOfType<String>(json, r'reason'),
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<RequestedDayView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RequestedDayView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RequestedDayView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RequestedDayView> mapFromJson(dynamic json) {
    final map = <String, RequestedDayView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RequestedDayView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RequestedDayView-objects as value to a dart map
  static Map<String, List<RequestedDayView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RequestedDayView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RequestedDayView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'availability',
    'baseDayId',
    'basePlanVersion',
    'cancel',
    'decidedAt',
    'decidedBy',
    'decision',
    'id',
    'localDate',
    'location',
    'reason',
    'version',
  };
}
