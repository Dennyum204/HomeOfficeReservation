//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeviceRegistrationView {
  /// Returns a new [DeviceRegistrationView] instance.
  DeviceRegistrationView({
    required this.expiresAt,
    required this.installationId,
    required this.provider,
    required this.version,
  });

  final DateTime expiresAt;

  final String installationId;

  final PushProvider provider;

  final int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeviceRegistrationView &&
    other.expiresAt == expiresAt &&
    other.installationId == installationId &&
    other.provider == provider &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expiresAt.hashCode) +
    (installationId.hashCode) +
    (provider.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'DeviceRegistrationView[expiresAt=$expiresAt, installationId=$installationId, provider=$provider, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'expiresAt'] = this.expiresAt.toUtc().toIso8601String();
      json[r'installationId'] = this.installationId;
      json[r'provider'] = this.provider;
      json[r'version'] = this.version;
    return json;
  }

  /// Clones this instance of [DeviceRegistrationView] and returns a new one where some of the
  /// properties have changed.
  DeviceRegistrationView copyWith({
    DateTime? expiresAt,
    String? installationId,
    PushProvider? provider,
    int? version,
  }) => DeviceRegistrationView(
    expiresAt: expiresAt ?? this.expiresAt,
    installationId: installationId ?? this.installationId,
    provider: provider ?? this.provider,
    version: version ?? this.version,
  );

  /// Returns a new [DeviceRegistrationView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeviceRegistrationView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expiresAt'), 'Required key "DeviceRegistrationView[expiresAt]" is missing from JSON.');
        assert(json[r'expiresAt'] != null, 'Required key "DeviceRegistrationView[expiresAt]" has a null value in JSON.');
        assert(json.containsKey(r'installationId'), 'Required key "DeviceRegistrationView[installationId]" is missing from JSON.');
        assert(json[r'installationId'] != null, 'Required key "DeviceRegistrationView[installationId]" has a null value in JSON.');
        assert(json.containsKey(r'provider'), 'Required key "DeviceRegistrationView[provider]" is missing from JSON.');
        assert(json[r'provider'] != null, 'Required key "DeviceRegistrationView[provider]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "DeviceRegistrationView[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "DeviceRegistrationView[version]" has a null value in JSON.');
        return true;
      }());

      return DeviceRegistrationView(
        expiresAt: mapDateTime(json, r'expiresAt', r'')!,
        installationId: mapValueOfType<String>(json, r'installationId')!,
        provider: PushProvider.fromJson(json[r'provider'])!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<DeviceRegistrationView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeviceRegistrationView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeviceRegistrationView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeviceRegistrationView> mapFromJson(dynamic json) {
    final map = <String, DeviceRegistrationView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeviceRegistrationView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeviceRegistrationView-objects as value to a dart map
  static Map<String, List<DeviceRegistrationView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeviceRegistrationView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeviceRegistrationView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expiresAt',
    'installationId',
    'provider',
    'version',
  };
}
