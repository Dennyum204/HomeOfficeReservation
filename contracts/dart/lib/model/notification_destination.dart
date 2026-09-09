//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationDestination {
  /// Returns a new [NotificationDestination] instance.
  NotificationDestination({
    required this.employeeId,
    required this.kind,
    required this.proposalId,
    required this.resourceId,
  });

  final String employeeId;

  final NotificationContext kind;

  final String? proposalId;

  final String resourceId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationDestination &&
    other.employeeId == employeeId &&
    other.kind == kind &&
    other.proposalId == proposalId &&
    other.resourceId == resourceId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (employeeId.hashCode) +
    (kind.hashCode) +
    (proposalId == null ? 0 : proposalId!.hashCode) +
    (resourceId.hashCode);

  @override
  String toString() => 'NotificationDestination[employeeId=$employeeId, kind=$kind, proposalId=$proposalId, resourceId=$resourceId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'employeeId'] = this.employeeId;
      json[r'kind'] = this.kind;
    if (this.proposalId != null) {
      json[r'proposalId'] = this.proposalId;
    } else {
      json[r'proposalId'] = null;
    }
      json[r'resourceId'] = this.resourceId;
    return json;
  }

  /// Clones this instance of [NotificationDestination] and returns a new one where some of the
  /// properties have changed.
  NotificationDestination copyWith({
    String? employeeId,
    NotificationContext? kind,
    String? proposalId,
    bool proposalIdSetToNull = false,
    String? resourceId,
  }) => NotificationDestination(
    employeeId: employeeId ?? this.employeeId,
    kind: kind ?? this.kind,
    proposalId: proposalIdSetToNull ? null : proposalId ?? this.proposalId,
    resourceId: resourceId ?? this.resourceId,
  );

  /// Returns a new [NotificationDestination] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationDestination? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'employeeId'), 'Required key "NotificationDestination[employeeId]" is missing from JSON.');
        assert(json[r'employeeId'] != null, 'Required key "NotificationDestination[employeeId]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "NotificationDestination[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "NotificationDestination[kind]" has a null value in JSON.');
        assert(json.containsKey(r'proposalId'), 'Required key "NotificationDestination[proposalId]" is missing from JSON.');
        assert(json.containsKey(r'resourceId'), 'Required key "NotificationDestination[resourceId]" is missing from JSON.');
        assert(json[r'resourceId'] != null, 'Required key "NotificationDestination[resourceId]" has a null value in JSON.');
        return true;
      }());

      return NotificationDestination(
        employeeId: mapValueOfType<String>(json, r'employeeId')!,
        kind: NotificationContext.fromJson(json[r'kind'])!,
        proposalId: mapValueOfType<String>(json, r'proposalId'),
        resourceId: mapValueOfType<String>(json, r'resourceId')!,
      );
    }
    return null;
  }

  static List<NotificationDestination> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationDestination>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationDestination.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationDestination> mapFromJson(dynamic json) {
    final map = <String, NotificationDestination>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationDestination.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationDestination-objects as value to a dart map
  static Map<String, List<NotificationDestination>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationDestination>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationDestination.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'employeeId',
    'kind',
    'proposalId',
    'resourceId',
  };
}
