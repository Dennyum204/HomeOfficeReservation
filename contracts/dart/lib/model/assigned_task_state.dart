//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


enum AssignedTaskState {
  todo._(r'Todo'),
  inProgress._(r'InProgress'),
  done._(r'Done'),
  cancelled._(r'Cancelled'),
  ;

  /// Instantiate a new enum with the provided value.
  const AssignedTaskState._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [AssignedTaskState] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static AssignedTaskState? fromJson(dynamic value) => AssignedTaskStateTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [AssignedTaskState]
  /// that were successfully decoded from the passed [JSON][json].
  static List<AssignedTaskState> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AssignedTaskState>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AssignedTaskState.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AssignedTaskState] to String,
/// and [decode] dynamic data back to [AssignedTaskState].
class AssignedTaskStateTypeTransformer {
  factory AssignedTaskStateTypeTransformer() => _instance ??= const AssignedTaskStateTypeTransformer._();

  const AssignedTaskStateTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(AssignedTaskState data) => data._value;

  /// Returns the instance of [AssignedTaskState] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AssignedTaskState? decode(dynamic data, {bool allowNull = true}) {
    if (data is AssignedTaskState) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'Todo': return AssignedTaskState.todo;
        case r'InProgress': return AssignedTaskState.inProgress;
        case r'Done': return AssignedTaskState.done;
        case r'Cancelled': return AssignedTaskState.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static AssignedTaskStateTypeTransformer? _instance;
}
