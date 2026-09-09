import 'package:homeoffice_api/api.dart';

import '../auth/auth_controller.dart';

class NotificationRepository {
  NotificationRepository(this.auth) : api = NotificationsApi(auth.client);
  final AuthController auth;
  final NotificationsApi api;
  Future<NotificationPage> list(int offset, String filter) =>
      auth.readAuthenticated(
        () async => (await api.listNotifications(
          offset: offset,
          limit: 20,
          unreadOnly: filter == 'unread',
          historical: filter == 'archive',
        ))!,
      );
  Future<int> count() => auth.readAuthenticated(
    () async => (await api.getNotificationUnreadCount())!.unreadCount,
  );
  Future<NotificationView> detail(String id) =>
      auth.readAuthenticated(() async => (await api.getNotification(id))!);
  Future<NotificationView> markRead(String id, bool read) async {
    await auth.check();
    if (auth.member == null) throw ApiException(401, '');
    return (await api
        .setNotificationRead(id, NotificationReadInput(read: read))
        .timeout(const Duration(seconds: 12)))!;
  }
}
