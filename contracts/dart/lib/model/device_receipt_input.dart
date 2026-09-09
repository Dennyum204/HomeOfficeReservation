//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeviceReceiptInput {
  /// Returns a new [DeviceReceiptInput] instance.
  DeviceReceiptInput({
    required this.installationId,
  });

  final String installationId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeviceReceiptInput &&
    other.installationId == installationId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (installationId.hashCode);

  @override
  String toString() => 'DeviceReceiptInput[installationId=$installationId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'installationId'] = this.installationId;
    return json;
  }

  /// Clones this instance of [DeviceReceiptInput] and returns a new one where some of the
  /// properties have changed.
  DeviceReceiptInput copyWith({
    String? installationId,
  }) => DeviceReceiptInput(
    installationId: installationId ?? this.installationId,
  );

  /// Returns a new [DeviceReceiptInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeviceReceiptInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'installationId'), 'Required key "DeviceReceiptInput[installationId]" is missing from JSON.');
        assert(json[r'installationId'] != null, 'Required key "DeviceReceiptInput[installationId]" has a null value in JSON.');
        return true;
      }());

      return DeviceReceiptInput(
        installationId: mapValueOfType<String>(json, r'installationId')!,
      );
    }
    return null;
  }

  static List<DeviceReceiptInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeviceReceiptInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeviceReceiptInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeviceReceiptInput> mapFromJson(dynamic json) {
    final map = <String, DeviceReceiptInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeviceReceiptInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeviceReceiptInput-objects as value to a dart map
  static Map<String, List<DeviceReceiptInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeviceReceiptInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeviceReceiptInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'installationId',
  };
}
