//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CommentView {
  /// Returns a new [CommentView] instance.
  CommentView({
    required this.authorId,
    required this.createdAt,
    required this.id,
    required this.proposalId,
    required this.requestId,
    required this.text,
  });

  final String authorId;

  final DateTime createdAt;

  final String id;

  final String? proposalId;

  final String requestId;

  final String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CommentView &&
    other.authorId == authorId &&
    other.createdAt == createdAt &&
    other.id == id &&
    other.proposalId == proposalId &&
    other.requestId == requestId &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authorId.hashCode) +
    (createdAt.hashCode) +
    (id.hashCode) +
    (proposalId == null ? 0 : proposalId!.hashCode) +
    (requestId.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'CommentView[authorId=$authorId, createdAt=$createdAt, id=$id, proposalId=$proposalId, requestId=$requestId, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authorId'] = this.authorId;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'id'] = this.id;
    if (this.proposalId != null) {
      json[r'proposalId'] = this.proposalId;
    } else {
      json[r'proposalId'] = null;
    }
      json[r'requestId'] = this.requestId;
      json[r'text'] = this.text;
    return json;
  }

  /// Clones this instance of [CommentView] and returns a new one where some of the
  /// properties have changed.
  CommentView copyWith({
    String? authorId,
    DateTime? createdAt,
    String? id,
    String? proposalId,
    bool proposalIdSetToNull = false,
    String? requestId,
    String? text,
  }) => CommentView(
    authorId: authorId ?? this.authorId,
    createdAt: createdAt ?? this.createdAt,
    id: id ?? this.id,
    proposalId: proposalIdSetToNull ? null : proposalId ?? this.proposalId,
    requestId: requestId ?? this.requestId,
    text: text ?? this.text,
  );

  /// Returns a new [CommentView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CommentView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'authorId'), 'Required key "CommentView[authorId]" is missing from JSON.');
        assert(json[r'authorId'] != null, 'Required key "CommentView[authorId]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "CommentView[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "CommentView[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "CommentView[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "CommentView[id]" has a null value in JSON.');
        assert(json.containsKey(r'proposalId'), 'Required key "CommentView[proposalId]" is missing from JSON.');
        assert(json.containsKey(r'requestId'), 'Required key "CommentView[requestId]" is missing from JSON.');
        assert(json[r'requestId'] != null, 'Required key "CommentView[requestId]" has a null value in JSON.');
        assert(json.containsKey(r'text'), 'Required key "CommentView[text]" is missing from JSON.');
        assert(json[r'text'] != null, 'Required key "CommentView[text]" has a null value in JSON.');
        return true;
      }());

      return CommentView(
        authorId: mapValueOfType<String>(json, r'authorId')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        id: mapValueOfType<String>(json, r'id')!,
        proposalId: mapValueOfType<String>(json, r'proposalId'),
        requestId: mapValueOfType<String>(json, r'requestId')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<CommentView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CommentView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CommentView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CommentView> mapFromJson(dynamic json) {
    final map = <String, CommentView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CommentView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CommentView-objects as value to a dart map
  static Map<String, List<CommentView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CommentView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CommentView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authorId',
    'createdAt',
    'id',
    'proposalId',
    'requestId',
    'text',
  };
}
