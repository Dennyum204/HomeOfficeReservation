//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationOperations {
  /// Returns a new [NotificationOperations] instance.
  NotificationOperations({
    required this.outboxFailed,
    required this.outboxPending,
    required this.providerAccepted,
    required this.pushFailed,
    required this.pushPending,
    required this.simulated,
  });

  final int outboxFailed;

  final int outboxPending;

  final int providerAccepted;

  final int pushFailed;

  final int pushPending;

  final int simulated;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationOperations &&
    other.outboxFailed == outboxFailed &&
    other.outboxPending == outboxPending &&
    other.providerAccepted == providerAccepted &&
    other.pushFailed == pushFailed &&
    other.pushPending == pushPending &&
    other.simulated == simulated;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (outboxFailed.hashCode) +
    (outboxPending.hashCode) +
    (providerAccepted.hashCode) +
    (pushFailed.hashCode) +
    (pushPending.hashCode) +
    (simulated.hashCode);

  @override
  String toString() => 'NotificationOperations[outboxFailed=$outboxFailed, outboxPending=$outboxPending, providerAccepted=$providerAccepted, pushFailed=$pushFailed, pushPending=$pushPending, simulated=$simulated]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'outboxFailed'] = this.outboxFailed;
      json[r'outboxPending'] = this.outboxPending;
      json[r'providerAccepted'] = this.providerAccepted;
      json[r'pushFailed'] = this.pushFailed;
      json[r'pushPending'] = this.pushPending;
      json[r'simulated'] = this.simulated;
    return json;
  }

  /// Clones this instance of [NotificationOperations] and returns a new one where some of the
  /// properties have changed.
  NotificationOperations copyWith({
    int? outboxFailed,
    int? outboxPending,
    int? providerAccepted,
    int? pushFailed,
    int? pushPending,
    int? simulated,
  }) => NotificationOperations(
    outboxFailed: outboxFailed ?? this.outboxFailed,
    outboxPending: outboxPending ?? this.outboxPending,
    providerAccepted: providerAccepted ?? this.providerAccepted,
    pushFailed: pushFailed ?? this.pushFailed,
    pushPending: pushPending ?? this.pushPending,
    simulated: simulated ?? this.simulated,
  );

  /// Returns a new [NotificationOperations] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationOperations? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'outboxFailed'), 'Required key "NotificationOperations[outboxFailed]" is missing from JSON.');
        assert(json[r'outboxFailed'] != null, 'Required key "NotificationOperations[outboxFailed]" has a null value in JSON.');
        assert(json.containsKey(r'outboxPending'), 'Required key "NotificationOperations[outboxPending]" is missing from JSON.');
        assert(json[r'outboxPending'] != null, 'Required key "NotificationOperations[outboxPending]" has a null value in JSON.');
        assert(json.containsKey(r'providerAccepted'), 'Required key "NotificationOperations[providerAccepted]" is missing from JSON.');
        assert(json[r'providerAccepted'] != null, 'Required key "NotificationOperations[providerAccepted]" has a null value in JSON.');
        assert(json.containsKey(r'pushFailed'), 'Required key "NotificationOperations[pushFailed]" is missing from JSON.');
        assert(json[r'pushFailed'] != null, 'Required key "NotificationOperations[pushFailed]" has a null value in JSON.');
        assert(json.containsKey(r'pushPending'), 'Required key "NotificationOperations[pushPending]" is missing from JSON.');
        assert(json[r'pushPending'] != null, 'Required key "NotificationOperations[pushPending]" has a null value in JSON.');
        assert(json.containsKey(r'simulated'), 'Required key "NotificationOperations[simulated]" is missing from JSON.');
        assert(json[r'simulated'] != null, 'Required key "NotificationOperations[simulated]" has a null value in JSON.');
        return true;
      }());

      return NotificationOperations(
        outboxFailed: mapValueOfType<int>(json, r'outboxFailed')!,
        outboxPending: mapValueOfType<int>(json, r'outboxPending')!,
        providerAccepted: mapValueOfType<int>(json, r'providerAccepted')!,
        pushFailed: mapValueOfType<int>(json, r'pushFailed')!,
        pushPending: mapValueOfType<int>(json, r'pushPending')!,
        simulated: mapValueOfType<int>(json, r'simulated')!,
      );
    }
    return null;
  }

  static List<NotificationOperations> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationOperations>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationOperations.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationOperations> mapFromJson(dynamic json) {
    final map = <String, NotificationOperations>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationOperations.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationOperations-objects as value to a dart map
  static Map<String, List<NotificationOperations>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationOperations>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationOperations.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'outboxFailed',
    'outboxPending',
    'providerAccepted',
    'pushFailed',
    'pushPending',
    'simulated',
  };
}
