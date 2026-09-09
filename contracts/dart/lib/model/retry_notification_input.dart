//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RetryNotificationInput {
  /// Returns a new [RetryNotificationInput] instance.
  RetryNotificationInput({
    required this.id,
    required this.push,
  });

  final String id;

  final bool push;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RetryNotificationInput &&
    other.id == id &&
    other.push == push;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (push.hashCode);

  @override
  String toString() => 'RetryNotificationInput[id=$id, push=$push]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'push'] = this.push;
    return json;
  }

  /// Clones this instance of [RetryNotificationInput] and returns a new one where some of the
  /// properties have changed.
  RetryNotificationInput copyWith({
    String? id,
    bool? push,
  }) => RetryNotificationInput(
    id: id ?? this.id,
    push: push ?? this.push,
  );

  /// Returns a new [RetryNotificationInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RetryNotificationInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "RetryNotificationInput[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "RetryNotificationInput[id]" has a null value in JSON.');
        assert(json.containsKey(r'push'), 'Required key "RetryNotificationInput[push]" is missing from JSON.');
        assert(json[r'push'] != null, 'Required key "RetryNotificationInput[push]" has a null value in JSON.');
        return true;
      }());

      return RetryNotificationInput(
        id: mapValueOfType<String>(json, r'id')!,
        push: mapValueOfType<bool>(json, r'push')!,
      );
    }
    return null;
  }

  static List<RetryNotificationInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RetryNotificationInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RetryNotificationInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RetryNotificationInput> mapFromJson(dynamic json) {
    final map = <String, RetryNotificationInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RetryNotificationInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RetryNotificationInput-objects as value to a dart map
  static Map<String, List<RetryNotificationInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RetryNotificationInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RetryNotificationInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'push',
  };
}
