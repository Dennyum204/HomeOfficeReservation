//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


enum DayDecision {
  pending._(r'Pending'),
  approved._(r'Approved'),
  rejected._(r'Rejected'),
  withdrawn._(r'Withdrawn'),
  superseded._(r'Superseded'),
  cancelled._(r'Cancelled'),
  ;

  /// Instantiate a new enum with the provided value.
  const DayDecision._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [DayDecision] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static DayDecision? fromJson(dynamic value) => DayDecisionTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [DayDecision]
  /// that were successfully decoded from the passed [JSON][json].
  static List<DayDecision> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DayDecision>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DayDecision.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DayDecision] to String,
/// and [decode] dynamic data back to [DayDecision].
class DayDecisionTypeTransformer {
  factory DayDecisionTypeTransformer() => _instance ??= const DayDecisionTypeTransformer._();

  const DayDecisionTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(DayDecision data) => data._value;

  /// Returns the instance of [DayDecision] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DayDecision? decode(dynamic data, {bool allowNull = true}) {
    if (data is DayDecision) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'Pending': return DayDecision.pending;
        case r'Approved': return DayDecision.approved;
        case r'Rejected': return DayDecision.rejected;
        case r'Withdrawn': return DayDecision.withdrawn;
        case r'Superseded': return DayDecision.superseded;
        case r'Cancelled': return DayDecision.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static DayDecisionTypeTransformer? _instance;
}
