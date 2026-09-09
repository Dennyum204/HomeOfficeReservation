import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

abstract class PushGateway {
  bool get configured;
  Stream<String> get opened;
  Stream<String> get foreground;
  Stream<String> get rotated;
  Future<void> initialize();
  Future<bool> permission();
  Future<bool> permissionGranted();
  Future<String> address();
  Future<void> reset();
  void dispose();
}

String? notificationLink(Map<String, dynamic> data) {
  final id = data['notificationId'];
  if (data['schema'] != '1' ||
      id is! String ||
      !RegExp(r'^[a-fA-F0-9]{8}(-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$')
          .hasMatch(id)) {
    return null;
  }
  return id;
}

class FirebasePushGateway implements PushGateway {
  final _opened = StreamController<String>.broadcast();
  final _foreground = StreamController<String>.broadcast();
  final _rotated = StreamController<String>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _ready = false;
  @override
  bool get configured =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      const bool.fromEnvironment('FCM_ENABLED');
  @override
  Stream<String> get opened => _opened.stream;
  @override
  Stream<String> get foreground => _foreground.stream;
  @override
  Stream<String> get rotated => _rotated.stream;
  @override
  Future<void> initialize() async {
    if (!configured || _ready) return;
    // Native resources come from the private external google-services.json build input.
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.setAutoInitEnabled(false);
    _ready = true;
    void emit(RemoteMessage message, StreamController<String> channel) {
      final id = notificationLink(message.data);
      if (id != null && !channel.isClosed) channel.add(id);
    }

    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen((m) => emit(m, _opened)),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((m) => emit(m, _foreground)),
    );
    _subscriptions.add(
      FirebaseMessaging.instance.onTokenRefresh.listen((_) async {
        try {
          final id = await FirebaseInstallations.instance.getId();
          if (!_rotated.isClosed) _rotated.add(id);
        } catch (_) {
          /* Next foreground synchronization retries without logging addresses. */
        }
      }),
    );
    _subscriptions.add(
      FirebaseInstallations.instance.onIdChange.listen((id) {
        if (!_rotated.isClosed) _rotated.add(id);
      }),
    );
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) emit(initial, _opened);
  }

  @override
  Future<bool> permission() async =>
      (await FirebaseMessaging.instance.requestPermission())
          .authorizationStatus ==
      AuthorizationStatus.authorized;
  @override
  Future<bool> permissionGranted() async =>
      (await FirebaseMessaging.instance.getNotificationSettings())
          .authorizationStatus ==
      AuthorizationStatus.authorized;
  @override
  Future<String> address() async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.getToken(); // SDK owns registration-token renewal. Never log or persist it ourselves.
    return FirebaseInstallations.instance
        .getId(); // Current FCM Admin API targets the FID.
  }

  @override
  Future<void> reset() async {
    if (!_ready) return;
    await FirebaseMessaging.instance.setAutoInitEnabled(false);
    await FirebaseMessaging.instance.deleteToken();
    await FirebaseInstallations.instance.delete();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_opened.close());
    unawaited(_foreground.close());
    unawaited(_rotated.close());
  }
}
