//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EmailRequest {
  /// Returns a new [EmailRequest] instance.
  EmailRequest({
    required this.email,
  });

  final String email;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EmailRequest &&
    other.email == email;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (email.hashCode);

  @override
  String toString() => 'EmailRequest[email=$email]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'email'] = this.email;
    return json;
  }

  /// Clones this instance of [EmailRequest] and returns a new one where some of the
  /// properties have changed.
  EmailRequest copyWith({
    String? email,
  }) => EmailRequest(
    email: email ?? this.email,
  );

  /// Returns a new [EmailRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EmailRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'email'), 'Required key "EmailRequest[email]" is missing from JSON.');
        assert(json[r'email'] != null, 'Required key "EmailRequest[email]" has a null value in JSON.');
        return true;
      }());

      return EmailRequest(
        email: mapValueOfType<String>(json, r'email')!,
      );
    }
    return null;
  }

  static List<EmailRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EmailRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EmailRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EmailRequest> mapFromJson(dynamic json) {
    final map = <String, EmailRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EmailRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EmailRequest-objects as value to a dart map
  static Map<String, List<EmailRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EmailRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EmailRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'email',
  };
}
