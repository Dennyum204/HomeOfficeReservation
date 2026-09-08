//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WorkspaceInfo {
  /// Returns a new [WorkspaceInfo] instance.
  WorkspaceInfo({
    required this.apiVersion,
    this.planningTimeZones = const [],
    required this.productName,
    required this.serverTimeUtc,
  });

  final String apiVersion;

  final List<String> planningTimeZones;

  final String productName;

  final DateTime serverTimeUtc;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkspaceInfo &&
    other.apiVersion == apiVersion &&
    _deepEquality.equals(other.planningTimeZones, planningTimeZones) &&
    other.productName == productName &&
    other.serverTimeUtc == serverTimeUtc;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (apiVersion.hashCode) +
    (planningTimeZones.hashCode) +
    (productName.hashCode) +
    (serverTimeUtc.hashCode);

  @override
  String toString() => 'WorkspaceInfo[apiVersion=$apiVersion, planningTimeZones=$planningTimeZones, productName=$productName, serverTimeUtc=$serverTimeUtc]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'apiVersion'] = this.apiVersion;
      json[r'planningTimeZones'] = this.planningTimeZones;
      json[r'productName'] = this.productName;
      json[r'serverTimeUtc'] = this.serverTimeUtc.toUtc().toIso8601String();
    return json;
  }

  /// Clones this instance of [WorkspaceInfo] and returns a new one where some of the
  /// properties have changed.
  WorkspaceInfo copyWith({
    String? apiVersion,
    List<String>? planningTimeZones,
    String? productName,
    DateTime? serverTimeUtc,
  }) => WorkspaceInfo(
    apiVersion: apiVersion ?? this.apiVersion,
    planningTimeZones: planningTimeZones ?? this.planningTimeZones,
    productName: productName ?? this.productName,
    serverTimeUtc: serverTimeUtc ?? this.serverTimeUtc,
  );

  /// Returns a new [WorkspaceInfo] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkspaceInfo? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'apiVersion'), 'Required key "WorkspaceInfo[apiVersion]" is missing from JSON.');
        assert(json[r'apiVersion'] != null, 'Required key "WorkspaceInfo[apiVersion]" has a null value in JSON.');
        assert(json.containsKey(r'planningTimeZones'), 'Required key "WorkspaceInfo[planningTimeZones]" is missing from JSON.');
        assert(json[r'planningTimeZones'] != null, 'Required key "WorkspaceInfo[planningTimeZones]" has a null value in JSON.');
        assert(json.containsKey(r'productName'), 'Required key "WorkspaceInfo[productName]" is missing from JSON.');
        assert(json[r'productName'] != null, 'Required key "WorkspaceInfo[productName]" has a null value in JSON.');
        assert(json.containsKey(r'serverTimeUtc'), 'Required key "WorkspaceInfo[serverTimeUtc]" is missing from JSON.');
        assert(json[r'serverTimeUtc'] != null, 'Required key "WorkspaceInfo[serverTimeUtc]" has a null value in JSON.');
        return true;
      }());

      return WorkspaceInfo(
        apiVersion: mapValueOfType<String>(json, r'apiVersion')!,
        planningTimeZones: json[r'planningTimeZones'] is Iterable
            ? (json[r'planningTimeZones'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        productName: mapValueOfType<String>(json, r'productName')!,
        serverTimeUtc: mapDateTime(json, r'serverTimeUtc', r'')!,
      );
    }
    return null;
  }

  static List<WorkspaceInfo> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkspaceInfo>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkspaceInfo.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkspaceInfo> mapFromJson(dynamic json) {
    final map = <String, WorkspaceInfo>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkspaceInfo.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkspaceInfo-objects as value to a dart map
  static Map<String, List<WorkspaceInfo>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkspaceInfo>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkspaceInfo.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'apiVersion',
    'planningTimeZones',
    'productName',
    'serverTimeUtc',
  };
}

