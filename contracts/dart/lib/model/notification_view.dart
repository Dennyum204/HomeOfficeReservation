//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationView {
  /// Returns a new [NotificationView] instance.
  NotificationView({
    required this.createdAt,
    required this.destination,
    required this.eventType,
    required this.historical,
    required this.id,
    required this.readAt,
  });

  final DateTime createdAt;

  final NotificationDestination? destination;

  final String eventType;

  final bool historical;

  final String id;

  final DateTime? readAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationView &&
    other.createdAt == createdAt &&
    other.destination == destination &&
    other.eventType == eventType &&
    other.historical == historical &&
    other.id == id &&
    other.readAt == readAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (createdAt.hashCode) +
    (destination == null ? 0 : destination!.hashCode) +
    (eventType.hashCode) +
    (historical.hashCode) +
    (id.hashCode) +
    (readAt == null ? 0 : readAt!.hashCode);

  @override
  String toString() => 'NotificationView[createdAt=$createdAt, destination=$destination, eventType=$eventType, historical=$historical, id=$id, readAt=$readAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    if (this.destination != null) {
      json[r'destination'] = this.destination;
    } else {
      json[r'destination'] = null;
    }
      json[r'eventType'] = this.eventType;
      json[r'historical'] = this.historical;
      json[r'id'] = this.id;
    if (this.readAt != null) {
      json[r'readAt'] = this.readAt!.toUtc().toIso8601String();
    } else {
      json[r'readAt'] = null;
    }
    return json;
  }

  /// Clones this instance of [NotificationView] and returns a new one where some of the
  /// properties have changed.
  NotificationView copyWith({
    DateTime? createdAt,
    NotificationDestination? destination,
    bool destinationSetToNull = false,
    String? eventType,
    bool? historical,
    String? id,
    DateTime? readAt,
    bool readAtSetToNull = false,
  }) => NotificationView(
    createdAt: createdAt ?? this.createdAt,
    destination: destinationSetToNull ? null : destination ?? this.destination,
    eventType: eventType ?? this.eventType,
    historical: historical ?? this.historical,
    id: id ?? this.id,
    readAt: readAtSetToNull ? null : readAt ?? this.readAt,
  );

  /// Returns a new [NotificationView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'createdAt'), 'Required key "NotificationView[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "NotificationView[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'destination'), 'Required key "NotificationView[destination]" is missing from JSON.');
        assert(json.containsKey(r'eventType'), 'Required key "NotificationView[eventType]" is missing from JSON.');
        assert(json[r'eventType'] != null, 'Required key "NotificationView[eventType]" has a null value in JSON.');
        assert(json.containsKey(r'historical'), 'Required key "NotificationView[historical]" is missing from JSON.');
        assert(json[r'historical'] != null, 'Required key "NotificationView[historical]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "NotificationView[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "NotificationView[id]" has a null value in JSON.');
        assert(json.containsKey(r'readAt'), 'Required key "NotificationView[readAt]" is missing from JSON.');
        return true;
      }());

      return NotificationView(
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        destination: NotificationDestination.fromJson(json[r'destination']),
        eventType: mapValueOfType<String>(json, r'eventType')!,
        historical: mapValueOfType<bool>(json, r'historical')!,
        id: mapValueOfType<String>(json, r'id')!,
        readAt: mapDateTime(json, r'readAt', r''),
      );
    }
    return null;
  }

  static List<NotificationView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationView> mapFromJson(dynamic json) {
    final map = <String, NotificationView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationView-objects as value to a dart map
  static Map<String, List<NotificationView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'createdAt',
    'destination',
    'eventType',
    'historical',
    'id',
    'readAt',
  };
}
