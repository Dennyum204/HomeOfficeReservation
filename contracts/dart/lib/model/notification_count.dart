//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationCount {
  /// Returns a new [NotificationCount] instance.
  NotificationCount({
    required this.unreadCount,
  });

  final int unreadCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationCount &&
    other.unreadCount == unreadCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (unreadCount.hashCode);

  @override
  String toString() => 'NotificationCount[unreadCount=$unreadCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'unreadCount'] = this.unreadCount;
    return json;
  }

  /// Clones this instance of [NotificationCount] and returns a new one where some of the
  /// properties have changed.
  NotificationCount copyWith({
    int? unreadCount,
  }) => NotificationCount(
    unreadCount: unreadCount ?? this.unreadCount,
  );

  /// Returns a new [NotificationCount] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationCount? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'unreadCount'), 'Required key "NotificationCount[unreadCount]" is missing from JSON.');
        assert(json[r'unreadCount'] != null, 'Required key "NotificationCount[unreadCount]" has a null value in JSON.');
        return true;
      }());

      return NotificationCount(
        unreadCount: mapValueOfType<int>(json, r'unreadCount')!,
      );
    }
    return null;
  }

  static List<NotificationCount> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationCount>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationCount.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationCount> mapFromJson(dynamic json) {
    final map = <String, NotificationCount>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationCount.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationCount-objects as value to a dart map
  static Map<String, List<NotificationCount>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationCount>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationCount.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'unreadCount',
  };
}
