//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MutationReceipt {
  /// Returns a new [MutationReceipt] instance.
  MutationReceipt({
    required this.calendarVersion,
    required this.contextId,
    required this.eventId,
    required this.version,
  });

  final int calendarVersion;

  final String contextId;

  final String eventId;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MutationReceipt &&
    other.calendarVersion == calendarVersion &&
    other.contextId == contextId &&
    other.eventId == eventId &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (calendarVersion.hashCode) +
    (contextId.hashCode) +
    (eventId.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'MutationReceipt[calendarVersion=$calendarVersion, contextId=$contextId, eventId=$eventId, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'calendarVersion'] = this.calendarVersion;
      json[r'contextId'] = this.contextId;
      json[r'eventId'] = this.eventId;
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [MutationReceipt] and returns a new one where some of the
  /// properties have changed.
  MutationReceipt copyWith({
    int? calendarVersion,
    String? contextId,
    String? eventId,
    int? version,
  }) => MutationReceipt(
    calendarVersion: calendarVersion ?? this.calendarVersion,
    contextId: contextId ?? this.contextId,
    eventId: eventId ?? this.eventId,
    version: version ?? this.version,
  );

  /// Returns a new [MutationReceipt] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MutationReceipt? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'calendarVersion'), 'Required key "MutationReceipt[calendarVersion]" is missing from JSON.');
        assert(json[r'calendarVersion'] != null, 'Required key "MutationReceipt[calendarVersion]" has a null value in JSON.');
        assert(json.containsKey(r'contextId'), 'Required key "MutationReceipt[contextId]" is missing from JSON.');
        assert(json[r'contextId'] != null, 'Required key "MutationReceipt[contextId]" has a null value in JSON.');
        assert(json.containsKey(r'eventId'), 'Required key "MutationReceipt[eventId]" is missing from JSON.');
        assert(json[r'eventId'] != null, 'Required key "MutationReceipt[eventId]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "MutationReceipt[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "MutationReceipt[version]" has a null value in JSON.');
        return true;
      }());

      return MutationReceipt(
        calendarVersion: mapValueOfType<int>(json, r'calendarVersion')!,
        contextId: mapValueOfType<String>(json, r'contextId')!,
        eventId: mapValueOfType<String>(json, r'eventId')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<MutationReceipt> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MutationReceipt>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MutationReceipt.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MutationReceipt> mapFromJson(dynamic json) {
    final map = <String, MutationReceipt>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MutationReceipt.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MutationReceipt-objects as value to a dart map
  static Map<String, List<MutationReceipt>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MutationReceipt>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MutationReceipt.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'calendarVersion',
    'contextId',
    'eventId',
    'version',
  };
}
