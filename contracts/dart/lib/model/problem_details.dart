//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProblemDetails {
  /// Returns a new [ProblemDetails] instance.
  ProblemDetails({
    this.detail,
    this.instance,
    this.status,
    this.title,
    this.type,
  });

  final String? detail;

  final String? instance;

  final int? status;

  final String? title;

  final String? type;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProblemDetails &&
    other.detail == detail &&
    other.instance == instance &&
    other.status == status &&
    other.title == title &&
    other.type == type;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (detail == null ? 0 : detail!.hashCode) +
    (instance == null ? 0 : instance!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (type == null ? 0 : type!.hashCode);

  @override
  String toString() => 'ProblemDetails[detail=$detail, instance=$instance, status=$status, title=$title, type=$type]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.detail != null) {
      json[r'detail'] = this.detail;
    } else {
      json[r'detail'] = null;
    }
    if (this.instance != null) {
      json[r'instance'] = this.instance;
    } else {
      json[r'instance'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    return json;
  }

  /// Clones this instance of [ProblemDetails] and returns a new one where some of the
  /// properties have changed.
  ProblemDetails copyWith({
    String? detail,
    bool detailSetToNull = false,
    String? instance,
    bool instanceSetToNull = false,
    int? status,
    bool statusSetToNull = false,
    String? title,
    bool titleSetToNull = false,
    String? type,
    bool typeSetToNull = false,
  }) => ProblemDetails(
    detail: detailSetToNull ? null : detail ?? this.detail,
    instance: instanceSetToNull ? null : instance ?? this.instance,
    status: statusSetToNull ? null : status ?? this.status,
    title: titleSetToNull ? null : title ?? this.title,
    type: typeSetToNull ? null : type ?? this.type,
  );

  /// Returns a new [ProblemDetails] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProblemDetails? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return ProblemDetails(
        detail: mapValueOfType<String>(json, r'detail'),
        instance: mapValueOfType<String>(json, r'instance'),
        status: mapValueOfType<int>(json, r'status'),
        title: mapValueOfType<String>(json, r'title'),
        type: mapValueOfType<String>(json, r'type'),
      );
    }
    return null;
  }

  static List<ProblemDetails> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProblemDetails>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProblemDetails.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProblemDetails> mapFromJson(dynamic json) {
    final map = <String, ProblemDetails>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProblemDetails.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProblemDetails-objects as value to a dart map
  static Map<String, List<ProblemDetails>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProblemDetails>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProblemDetails.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}
