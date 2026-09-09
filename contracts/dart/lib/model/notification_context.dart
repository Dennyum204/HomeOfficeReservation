//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


enum NotificationContext {
  request._(r'Request'),
  proposal._(r'Proposal'),
  requirement._(r'Requirement'),
  task._(r'Task'),
  ;

  /// Instantiate a new enum with the provided value.
  const NotificationContext._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [NotificationContext] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static NotificationContext? fromJson(dynamic value) => NotificationContextTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [NotificationContext]
  /// that were successfully decoded from the passed [JSON][json].
  static List<NotificationContext> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationContext>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationContext.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [NotificationContext] to String,
/// and [decode] dynamic data back to [NotificationContext].
class NotificationContextTypeTransformer {
  factory NotificationContextTypeTransformer() => _instance ??= const NotificationContextTypeTransformer._();

  const NotificationContextTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(NotificationContext data) => data._value;

  /// Returns the instance of [NotificationContext] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  NotificationContext? decode(dynamic data, {bool allowNull = true}) {
    if (data is NotificationContext) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'Request': return NotificationContext.request;
        case r'Proposal': return NotificationContext.proposal;
        case r'Requirement': return NotificationContext.requirement;
        case r'Task': return NotificationContext.task;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static NotificationContextTypeTransformer? _instance;
}
