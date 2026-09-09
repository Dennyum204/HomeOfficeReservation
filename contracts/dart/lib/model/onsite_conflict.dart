//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OnsiteConflict {
  /// Returns a new [OnsiteConflict] instance.
  OnsiteConflict({
    required this.code,
    required this.contextId,
    required this.localDate,
    required this.requestId,
  });

  final String code;

  final String contextId;

  final DateTime localDate;

  final String? requestId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OnsiteConflict &&
    other.code == code &&
    other.contextId == contextId &&
    other.localDate == localDate &&
    other.requestId == requestId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (contextId.hashCode) +
    (localDate.hashCode) +
    (requestId == null ? 0 : requestId!.hashCode);

  @override
  String toString() => 'OnsiteConflict[code=$code, contextId=$contextId, localDate=$localDate, requestId=$requestId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'contextId'] = this.contextId;
      json[r'localDate'] = _dateFormatter.format(this.localDate);
    if (this.requestId != null) {
      json[r'requestId'] = this.requestId;
    } else {
      json[r'requestId'] = null;
    }
    return json;
  }

  /// Clones this instance of [OnsiteConflict] and returns a new one where some of the
  /// properties have changed.
  OnsiteConflict copyWith({
    String? code,
    String? contextId,
    DateTime? localDate,
    String? requestId,
    bool requestIdSetToNull = false,
  }) => OnsiteConflict(
    code: code ?? this.code,
    contextId: contextId ?? this.contextId,
    localDate: localDate ?? this.localDate,
    requestId: requestIdSetToNull ? null : requestId ?? this.requestId,
  );

  /// Returns a new [OnsiteConflict] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OnsiteConflict? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'code'), 'Required key "OnsiteConflict[code]" is missing from JSON.');
        assert(json[r'code'] != null, 'Required key "OnsiteConflict[code]" has a null value in JSON.');
        assert(json.containsKey(r'contextId'), 'Required key "OnsiteConflict[contextId]" is missing from JSON.');
        assert(json[r'contextId'] != null, 'Required key "OnsiteConflict[contextId]" has a null value in JSON.');
        assert(json.containsKey(r'localDate'), 'Required key "OnsiteConflict[localDate]" is missing from JSON.');
        assert(json[r'localDate'] != null, 'Required key "OnsiteConflict[localDate]" has a null value in JSON.');
        assert(json.containsKey(r'requestId'), 'Required key "OnsiteConflict[requestId]" is missing from JSON.');
        return true;
      }());

      return OnsiteConflict(
        code: mapValueOfType<String>(json, r'code')!,
        contextId: mapValueOfType<String>(json, r'contextId')!,
        localDate: mapDateTime(json, r'localDate', r'')!,
        requestId: mapValueOfType<String>(json, r'requestId'),
      );
    }
    return null;
  }

  static List<OnsiteConflict> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OnsiteConflict>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OnsiteConflict.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OnsiteConflict> mapFromJson(dynamic json) {
    final map = <String, OnsiteConflict>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OnsiteConflict.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OnsiteConflict-objects as value to a dart map
  static Map<String, List<OnsiteConflict>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OnsiteConflict>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OnsiteConflict.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'contextId',
    'localDate',
    'requestId',
  };
}
