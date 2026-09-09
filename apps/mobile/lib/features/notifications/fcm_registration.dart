import 'dart:async';

import 'package:flutter/services.dart';

/// Calls the maintained Android SDK's FID APIs, unavailable in FlutterFire 16.6.0.
class FcmRegistration {
  static const _channel = MethodChannel('homeoffice/fcm-registration');
  final _changes = StreamController<String>.broadcast();
  String? _lastAddress;
  bool _disposed = false;

  Stream<String> get changes => _changes.stream;

  void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (_disposed || call.method != 'registered') return;
      final value = call.arguments;
      if (value is String && _valid(value) && value != _lastAddress) {
        _lastAddress = value;
        _changes.add(value);
      }
    });
  }

  static bool _valid(String value) =>
      RegExp(r'^[A-Za-z0-9_-]{22}$').hasMatch(value);

  Future<String> register() async {
    final value = await _channel.invokeMethod<String>('register');
    if (value == null || !_valid(value)) {
      throw const FormatException('invalid_fcm_registration');
    }
    _lastAddress = value;
    return value;
  }

  Future<void> reset() async {
    await _channel.invokeMethod<void>('reset');
    _lastAddress = null;
  }

  void dispose() {
    _disposed = true;
    _channel.setMethodCallHandler(null);
    unawaited(_changes.close());
  }
}
