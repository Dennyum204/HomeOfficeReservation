import 'package:flutter/services.dart';

/// Android system alerts contain only a generic message and an opaque inbox ID.
class NotificationAlerts {
  static const channel = MethodChannel('homeoffice/notification-alerts');
  static Future<void> show(String id) async {
    try {
      await channel.invokeMethod<void>('show', id);
    } on PlatformException {
      // Inbox remains authoritative if Android cannot present an alert.
    } on MissingPluginException {
      // Platforms without the Android bridge keep their internal inbox.
    }
  }
}
