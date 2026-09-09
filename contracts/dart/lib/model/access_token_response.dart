//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AccessTokenResponse {
  /// Returns a new [AccessTokenResponse] instance.
  AccessTokenResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    this.tokenType,
  });

  final String accessToken;

  final Object? expiresIn;

  final String refreshToken;

  final String? tokenType;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AccessTokenResponse &&
    other.accessToken == accessToken &&
    other.expiresIn == expiresIn &&
    other.refreshToken == refreshToken &&
    other.tokenType == tokenType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (accessToken.hashCode) +
    (expiresIn == null ? 0 : expiresIn!.hashCode) +
    (refreshToken.hashCode) +
    (tokenType == null ? 0 : tokenType!.hashCode);

  @override
  String toString() => 'AccessTokenResponse[accessToken=$accessToken, expiresIn=$expiresIn, refreshToken=$refreshToken, tokenType=$tokenType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'accessToken'] = this.accessToken;
    if (this.expiresIn != null) {
      json[r'expiresIn'] = this.expiresIn;
    } else {
      json[r'expiresIn'] = null;
    }
      json[r'refreshToken'] = this.refreshToken;
    if (this.tokenType != null) {
      json[r'tokenType'] = this.tokenType;
    } else {
      json[r'tokenType'] = null;
    }
    return json;
  }

  /// Clones this instance of [AccessTokenResponse] and returns a new one where some of the
  /// properties have changed.
  AccessTokenResponse copyWith({
    String? accessToken,
    Object? expiresIn,
    bool expiresInSetToNull = false,
    String? refreshToken,
    String? tokenType,
    bool tokenTypeSetToNull = false,
  }) => AccessTokenResponse(
    accessToken: accessToken ?? this.accessToken,
    expiresIn: expiresInSetToNull ? null : expiresIn ?? this.expiresIn,
    refreshToken: refreshToken ?? this.refreshToken,
    tokenType: tokenTypeSetToNull ? null : tokenType ?? this.tokenType,
  );

  /// Returns a new [AccessTokenResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AccessTokenResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'accessToken'), 'Required key "AccessTokenResponse[accessToken]" is missing from JSON.');
        assert(json[r'accessToken'] != null, 'Required key "AccessTokenResponse[accessToken]" has a null value in JSON.');
        assert(json.containsKey(r'expiresIn'), 'Required key "AccessTokenResponse[expiresIn]" is missing from JSON.');
        assert(json.containsKey(r'refreshToken'), 'Required key "AccessTokenResponse[refreshToken]" is missing from JSON.');
        assert(json[r'refreshToken'] != null, 'Required key "AccessTokenResponse[refreshToken]" has a null value in JSON.');
        return true;
      }());

      return AccessTokenResponse(
        accessToken: mapValueOfType<String>(json, r'accessToken')!,
        expiresIn: mapValueOfType<Object>(json, r'expiresIn'),
        refreshToken: mapValueOfType<String>(json, r'refreshToken')!,
        tokenType: mapValueOfType<String>(json, r'tokenType'),
      );
    }
    return null;
  }

  static List<AccessTokenResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AccessTokenResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AccessTokenResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AccessTokenResponse> mapFromJson(dynamic json) {
    final map = <String, AccessTokenResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AccessTokenResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AccessTokenResponse-objects as value to a dart map
  static Map<String, List<AccessTokenResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AccessTokenResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AccessTokenResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'accessToken',
    'expiresIn',
    'refreshToken',
  };
}
