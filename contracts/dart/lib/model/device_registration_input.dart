//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeviceRegistrationInput {
  /// Returns a new [DeviceRegistrationInput] instance.
  DeviceRegistrationInput({
    required this.address,
    required this.expectedVersion,
    required this.installationId,
    required this.provider,
  });

  final String address;

  final int? expectedVersion;

  final String installationId;

  final PushProvider provider;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeviceRegistrationInput &&
    other.address == address &&
    other.expectedVersion == expectedVersion &&
    other.installationId == installationId &&
    other.provider == provider;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (address.hashCode) +
    (expectedVersion == null ? 0 : expectedVersion!.hashCode) +
    (installationId.hashCode) +
    (provider.hashCode);

  @override
  String toString() => 'DeviceRegistrationInput[address=$address, expectedVersion=$expectedVersion, installationId=$installationId, provider=$provider]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'address'] = this.address;
    if (this.expectedVersion != null) {
      json[r'expectedVersion'] = this.expectedVersion;
    } else {
      json[r'expectedVersion'] = null;
    }
      json[r'installationId'] = this.installationId;
      json[r'provider'] = this.provider;
    return json;
  }

  /// Clones this instance of [DeviceRegistrationInput] and returns a new one where some of the
  /// properties have changed.
  DeviceRegistrationInput copyWith({
    String? address,
    int? expectedVersion,
    bool expectedVersionSetToNull = false,
    String? installationId,
    PushProvider? provider,
  }) => DeviceRegistrationInput(
    address: address ?? this.address,
    expectedVersion: expectedVersionSetToNull ? null : expectedVersion ?? this.expectedVersion,
    installationId: installationId ?? this.installationId,
    provider: provider ?? this.provider,
  );

  /// Returns a new [DeviceRegistrationInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeviceRegistrationInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'address'), 'Required key "DeviceRegistrationInput[address]" is missing from JSON.');
        assert(json[r'address'] != null, 'Required key "DeviceRegistrationInput[address]" has a null value in JSON.');
        assert(json.containsKey(r'expectedVersion'), 'Required key "DeviceRegistrationInput[expectedVersion]" is missing from JSON.');
        assert(json.containsKey(r'installationId'), 'Required key "DeviceRegistrationInput[installationId]" is missing from JSON.');
        assert(json[r'installationId'] != null, 'Required key "DeviceRegistrationInput[installationId]" has a null value in JSON.');
        assert(json.containsKey(r'provider'), 'Required key "DeviceRegistrationInput[provider]" is missing from JSON.');
        assert(json[r'provider'] != null, 'Required key "DeviceRegistrationInput[provider]" has a null value in JSON.');
        return true;
      }());

      return DeviceRegistrationInput(
        address: mapValueOfType<String>(json, r'address')!,
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion'),
        installationId: mapValueOfType<String>(json, r'installationId')!,
        provider: PushProvider.fromJson(json[r'provider'])!,
      );
    }
    return null;
  }

  static List<DeviceRegistrationInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeviceRegistrationInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeviceRegistrationInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeviceRegistrationInput> mapFromJson(dynamic json) {
    final map = <String, DeviceRegistrationInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeviceRegistrationInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeviceRegistrationInput-objects as value to a dart map
  static Map<String, List<DeviceRegistrationInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeviceRegistrationInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeviceRegistrationInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'address',
    'expectedVersion',
    'installationId',
    'provider',
  };
}
