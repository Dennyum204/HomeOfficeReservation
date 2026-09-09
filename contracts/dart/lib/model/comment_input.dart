//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CommentInput {
  /// Returns a new [CommentInput] instance.
  CommentInput({
    required this.expectedCalendarVersion,
    this.proposalId,
    required this.text,
  });

  final int? expectedCalendarVersion;

  final String? proposalId;

  final String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CommentInput &&
    other.expectedCalendarVersion == expectedCalendarVersion &&
    other.proposalId == proposalId &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedCalendarVersion == null ? 0 : expectedCalendarVersion!.hashCode) +
    (proposalId == null ? 0 : proposalId!.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'CommentInput[expectedCalendarVersion=$expectedCalendarVersion, proposalId=$proposalId, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.expectedCalendarVersion != null) {
      json[r'expectedCalendarVersion'] = this.expectedCalendarVersion;
    } else {
      json[r'expectedCalendarVersion'] = null;
    }
    if (this.proposalId != null) {
      json[r'proposalId'] = this.proposalId;
    } else {
      json[r'proposalId'] = null;
    }
      json[r'text'] = this.text;
    return json;
  }

  /// Clones this instance of [CommentInput] and returns a new one where some of the
  /// properties have changed.
  CommentInput copyWith({
    int? expectedCalendarVersion,
    bool expectedCalendarVersionSetToNull = false,
    String? proposalId,
    bool proposalIdSetToNull = false,
    String? text,
  }) => CommentInput(
    expectedCalendarVersion: expectedCalendarVersionSetToNull ? null : expectedCalendarVersion ?? this.expectedCalendarVersion,
    proposalId: proposalIdSetToNull ? null : proposalId ?? this.proposalId,
    text: text ?? this.text,
  );

  /// Returns a new [CommentInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CommentInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedCalendarVersion'), 'Required key "CommentInput[expectedCalendarVersion]" is missing from JSON.');
        assert(json.containsKey(r'text'), 'Required key "CommentInput[text]" is missing from JSON.');
        assert(json[r'text'] != null, 'Required key "CommentInput[text]" has a null value in JSON.');
        return true;
      }());

      return CommentInput(
        expectedCalendarVersion: mapValueOfType<int>(json, r'expectedCalendarVersion'),
        proposalId: mapValueOfType<String>(json, r'proposalId'),
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<CommentInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CommentInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CommentInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CommentInput> mapFromJson(dynamic json) {
    final map = <String, CommentInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CommentInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CommentInput-objects as value to a dart map
  static Map<String, List<CommentInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CommentInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CommentInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedCalendarVersion',
    'text',
  };
}
