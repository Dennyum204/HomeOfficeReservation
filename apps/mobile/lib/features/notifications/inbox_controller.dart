import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:homeoffice_api/api.dart';

import 'notification_repository.dart';

class InboxController extends ChangeNotifier {
  InboxController(this.repository);
  final NotificationRepository repository;
  NotificationPage? page;
  NotificationView? detail;
  int unreadCount = 0;
  int offset = 0;
  String filter = 'all';
  bool loading = false;
  bool busy = false;
  bool error = false;
  bool unavailable = false;
  bool visible = true;
  bool inboxOpen = false;
  bool _disposed = false;
  int _generation = 0;
  Timer? _timer;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() async {
    _timer?.cancel();
    if (_disposed || !visible || loading) return;
    final generation = _generation;
    loading = true;
    error = false;
    _notify();
    try {
      if (inboxOpen) {
        final result = await repository.list(offset, filter);
        if (!_disposed && generation == _generation) {
          page = result;
          unreadCount = result.unreadCount;
        }
      } else {
        final count = await repository.count();
        if (!_disposed && generation == _generation) unreadCount = count;
      }
    } catch (_) {
      if (!_disposed && generation == _generation) error = true;
    } finally {
      if (!_disposed) {
        loading = false;
        _notify();
        if (visible) _timer = Timer(const Duration(seconds: 15), refresh);
      }
    }
  }

  void activity(bool active) {
    visible = active;
    _timer?.cancel();
    if (active) unawaited(refresh());
  }

  void showInbox(bool show) {
    inboxOpen = show;
    if (show) unawaited(refresh());
  }

  Future<void> selectFilter(String value) async {
    filter = value;
    offset = 0;
    page = null;
    _generation++;
    // A read already in flight is discarded; schedule the new filter once it completes.
    while (loading && !_disposed) {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
    await refresh();
  }

  Future<void> next(int value) async {
    offset = value;
    page = null;
    await refresh();
  }

  Future<void> open(String id) async {
    if (busy || _disposed) return;
    final generation = _generation;
    busy = true;
    detail = null;
    error = false;
    unavailable = false;
    _notify();
    try {
      final result = await repository.detail(id);
      if (!_disposed && generation == _generation) detail = result;
    } catch (failure) {
      if (!_disposed && generation == _generation) {
        unavailable = failure is ApiException && failure.code == 404;
        error = !unavailable;
      }
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> read(NotificationView item) async {
    if (busy || _disposed) return;
    final generation = _generation;
    busy = true;
    error = false;
    _notify();
    try {
      final result = await repository.markRead(item.id, item.readAt == null);
      if (!_disposed && generation == _generation) {
        if (detail?.id == result.id) detail = result;
        while (loading && !_disposed) {
          await Future<void>.delayed(const Duration(milliseconds: 30));
        }
        await refresh();
      }
    } catch (_) {
      if (!_disposed && generation == _generation) error = true;
    } finally {
      busy = false;
      _notify();
    }
  }

  void closeDetail() {
    detail = null;
    unavailable = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _timer?.cancel();
    super.dispose();
  }
}
