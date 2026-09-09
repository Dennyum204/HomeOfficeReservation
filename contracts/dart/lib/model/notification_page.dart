//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationPage {
  /// Returns a new [NotificationPage] instance.
  NotificationPage({
    this.items = const [],
    required this.nextOffset,
    required this.unreadCount,
  });

  final List<NotificationView> items;

  final int? nextOffset;

  final int unreadCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationPage &&
    _deepEquality.equals(other.items, items) &&
    other.nextOffset == nextOffset &&
    other.unreadCount == unreadCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (nextOffset == null ? 0 : nextOffset!.hashCode) +
    (unreadCount.hashCode);

  @override
  String toString() => 'NotificationPage[items=$items, nextOffset=$nextOffset, unreadCount=$unreadCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
    if (this.nextOffset != null) {
      json[r'nextOffset'] = this.nextOffset;
    } else {
      json[r'nextOffset'] = null;
    }
      json[r'unreadCount'] = this.unreadCount;
    return json;
  }

  /// Clones this instance of [NotificationPage] and returns a new one where some of the
  /// properties have changed.
  NotificationPage copyWith({
    List<NotificationView>? items,
    int? nextOffset,
    bool nextOffsetSetToNull = false,
    int? unreadCount,
  }) => NotificationPage(
    items: items ?? this.items,
    nextOffset: nextOffsetSetToNull ? null : nextOffset ?? this.nextOffset,
    unreadCount: unreadCount ?? this.unreadCount,
  );

  /// Returns a new [NotificationPage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationPage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'items'), 'Required key "NotificationPage[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "NotificationPage[items]" has a null value in JSON.');
        assert(json.containsKey(r'nextOffset'), 'Required key "NotificationPage[nextOffset]" is missing from JSON.');
        assert(json.containsKey(r'unreadCount'), 'Required key "NotificationPage[unreadCount]" is missing from JSON.');
        assert(json[r'unreadCount'] != null, 'Required key "NotificationPage[unreadCount]" has a null value in JSON.');
        return true;
      }());

      return NotificationPage(
        items: NotificationView.listFromJson(json[r'items']),
        nextOffset: mapValueOfType<int>(json, r'nextOffset'),
        unreadCount: mapValueOfType<int>(json, r'unreadCount')!,
      );
    }
    return null;
  }

  static List<NotificationPage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationPage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationPage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationPage> mapFromJson(dynamic json) {
    final map = <String, NotificationPage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationPage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationPage-objects as value to a dart map
  static Map<String, List<NotificationPage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationPage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationPage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'nextOffset',
    'unreadCount',
  };
}
