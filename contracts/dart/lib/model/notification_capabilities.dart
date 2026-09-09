//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationCapabilities {
  /// Returns a new [NotificationCapabilities] instance.
  NotificationCapabilities({
    required this.provider,
  });

  final PushProvider provider;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationCapabilities &&
    other.provider == provider;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (provider.hashCode);

  @override
  String toString() => 'NotificationCapabilities[provider=$provider]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'provider'] = this.provider;
    return json;
  }

  /// Clones this instance of [NotificationCapabilities] and returns a new one where some of the
  /// properties have changed.
  NotificationCapabilities copyWith({
    PushProvider? provider,
  }) => NotificationCapabilities(
    provider: provider ?? this.provider,
  );

  /// Returns a new [NotificationCapabilities] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationCapabilities? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'provider'), 'Required key "NotificationCapabilities[provider]" is missing from JSON.');
        assert(json[r'provider'] != null, 'Required key "NotificationCapabilities[provider]" has a null value in JSON.');
        return true;
      }());

      return NotificationCapabilities(
        provider: PushProvider.fromJson(json[r'provider'])!,
      );
    }
    return null;
  }

  static List<NotificationCapabilities> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationCapabilities>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationCapabilities.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationCapabilities> mapFromJson(dynamic json) {
    final map = <String, NotificationCapabilities>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationCapabilities.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationCapabilities-objects as value to a dart map
  static Map<String, List<NotificationCapabilities>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationCapabilities>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationCapabilities.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'provider',
  };
}
