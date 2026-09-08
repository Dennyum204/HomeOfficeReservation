//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CsrfToken {
  /// Returns a new [CsrfToken] instance.
  CsrfToken({
    required this.requestToken,
  });

  final String requestToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CsrfToken &&
    other.requestToken == requestToken;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (requestToken.hashCode);

  @override
  String toString() => 'CsrfToken[requestToken=$requestToken]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'requestToken'] = this.requestToken;
    return json;
  }

  /// Clones this instance of [CsrfToken] and returns a new one where some of the
  /// properties have changed.
  CsrfToken copyWith({
    String? requestToken,
  }) => CsrfToken(
    requestToken: requestToken ?? this.requestToken,
  );

  /// Returns a new [CsrfToken] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CsrfToken? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'requestToken'), 'Required key "CsrfToken[requestToken]" is missing from JSON.');
        assert(json[r'requestToken'] != null, 'Required key "CsrfToken[requestToken]" has a null value in JSON.');
        return true;
      }());

      return CsrfToken(
        requestToken: mapValueOfType<String>(json, r'requestToken')!,
      );
    }
    return null;
  }

  static List<CsrfToken> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CsrfToken>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CsrfToken.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CsrfToken> mapFromJson(dynamic json) {
    final map = <String, CsrfToken>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CsrfToken.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CsrfToken-objects as value to a dart map
  static Map<String, List<CsrfToken>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CsrfToken>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CsrfToken.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'requestToken',
  };
}
