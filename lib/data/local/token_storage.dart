import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _keyAccess = 'access_token';
  static const _keyServer = 'mealie_server';

  Future<void> saveToken(String token) => _storage.write(key: _keyAccess, value: token);
  Future<String?> getToken() => _storage.read(key: _keyAccess);
  Future<void> deleteToken() => _storage.delete(key: _keyAccess);

  Future<void> saveServerUrl(String url) => _storage.write(key: _keyServer, value: url);
  Future<String?> getServerUrl() => _storage.read(key: _keyServer);
}