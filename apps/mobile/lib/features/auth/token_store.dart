import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String refresh);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore(String baseUrl)
    : _key = 'homeoffice.refresh.${Uri.parse(baseUrl).origin}';
  final String _key;
  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String refresh) =>
      _storage.write(key: _key, value: refresh);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}
