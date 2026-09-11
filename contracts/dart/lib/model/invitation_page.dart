//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InvitationPage {
  /// Returns a new [InvitationPage] instance.
  InvitationPage({
    this.members = const [],
    required this.nextAfter,
  });

  final List<InvitationProfile> members;

  final String? nextAfter;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InvitationPage &&
    _deepEquality.equals(other.members, members) &&
    other.nextAfter == nextAfter;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (members.hashCode) +
    (nextAfter == null ? 0 : nextAfter!.hashCode);

  @override
  String toString() => 'InvitationPage[members=$members, nextAfter=$nextAfter]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'members'] = this.members;
    if (this.nextAfter != null) {
      json[r'nextAfter'] = this.nextAfter;
    } else {
      json[r'nextAfter'] = null;
    }
    return json;
  }

  /// Clones this instance of [InvitationPage] and returns a new one where some of the
  /// properties have changed.
  InvitationPage copyWith({
    List<InvitationProfile>? members,
    String? nextAfter,
    bool nextAfterSetToNull = false,
  }) => InvitationPage(
    members: members ?? this.members,
    nextAfter: nextAfterSetToNull ? null : nextAfter ?? this.nextAfter,
  );

  /// Returns a new [InvitationPage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InvitationPage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'members'), 'Required key "InvitationPage[members]" is missing from JSON.');
        assert(json[r'members'] != null, 'Required key "InvitationPage[members]" has a null value in JSON.');
        assert(json.containsKey(r'nextAfter'), 'Required key "InvitationPage[nextAfter]" is missing from JSON.');
        return true;
      }());

      return InvitationPage(
        members: InvitationProfile.listFromJson(json[r'members']),
        nextAfter: mapValueOfType<String>(json, r'nextAfter'),
      );
    }
    return null;
  }

  static List<InvitationPage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InvitationPage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InvitationPage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InvitationPage> mapFromJson(dynamic json) {
    final map = <String, InvitationPage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InvitationPage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InvitationPage-objects as value to a dart map
  static Map<String, List<InvitationPage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InvitationPage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InvitationPage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'members',
    'nextAfter',
  };
}
