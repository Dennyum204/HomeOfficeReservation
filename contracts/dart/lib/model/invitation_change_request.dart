//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InvitationChangeRequest {
  /// Returns a new [InvitationChangeRequest] instance.
  InvitationChangeRequest({
    required this.commandId,
    required this.expectedVersion,
  });

  final String commandId;

  final int expectedVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InvitationChangeRequest &&
    other.commandId == commandId &&
    other.expectedVersion == expectedVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (commandId.hashCode) +
    (expectedVersion.hashCode);

  @override
  String toString() => 'InvitationChangeRequest[commandId=$commandId, expectedVersion=$expectedVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'commandId'] = this.commandId;
      json[r'expectedVersion'] = this.expectedVersion;
    return json;
  }

  /// Clones this instance of [InvitationChangeRequest] and returns a new one where some of the
  /// properties have changed.
  InvitationChangeRequest copyWith({
    String? commandId,
    int? expectedVersion,
  }) => InvitationChangeRequest(
    commandId: commandId ?? this.commandId,
    expectedVersion: expectedVersion ?? this.expectedVersion,
  );

  /// Returns a new [InvitationChangeRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InvitationChangeRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'commandId'), 'Required key "InvitationChangeRequest[commandId]" is missing from JSON.');
        assert(json[r'commandId'] != null, 'Required key "InvitationChangeRequest[commandId]" has a null value in JSON.');
        assert(json.containsKey(r'expectedVersion'), 'Required key "InvitationChangeRequest[expectedVersion]" is missing from JSON.');
        assert(json[r'expectedVersion'] != null, 'Required key "InvitationChangeRequest[expectedVersion]" has a null value in JSON.');
        return true;
      }());

      return InvitationChangeRequest(
        commandId: mapValueOfType<String>(json, r'commandId')!,
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion')!,
      );
    }
    return null;
  }

  static List<InvitationChangeRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InvitationChangeRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InvitationChangeRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InvitationChangeRequest> mapFromJson(dynamic json) {
    final map = <String, InvitationChangeRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InvitationChangeRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InvitationChangeRequest-objects as value to a dart map
  static Map<String, List<InvitationChangeRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InvitationChangeRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InvitationChangeRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'commandId',
    'expectedVersion',
  };
}
