import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class PlanningStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

// One encrypted record per API origin. Actor validation is mandatory on restore.
// Serialize writes/deletion across controller replacement during account changes.
class SecurePlanningStore implements PlanningStore {
  SecurePlanningStore(String origin) : key = 'HomeOffice.Planning.$origin';
  final String key;
  static final Map<String, Future<void>> _queues = {};
  final _storage = const FlutterSecureStorage();
  Future<void> _queue(Future<void> Function() action) {
    final next = (_queues[key] ?? Future<void>.value()).then((_) => action());
    _queues[key] = next.catchError((Object _) {});
    return next;
  }

  @override
  Future<String?> read() async {
    await _queues[key];
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String value) =>
      _queue(() => _storage.write(key: key, value: value));
  @override
  Future<void> clear() => _queue(() => _storage.delete(key: key));
}
