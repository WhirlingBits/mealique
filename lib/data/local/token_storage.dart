import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _keyAccess = 'access_token';
  static const _keyServer = 'mealie_server';
  static const _keyUsername = 'mealie_username';
  static const _keyPassword = 'mealie_password';
  static const _keyUserId = 'mealie_user_id';

  // --- Token ---
  Future<void> saveToken(String token) => _storage.write(key: _keyAccess, value: token);
  Future<String?> getToken() => _storage.read(key: _keyAccess);
  Future<void> deleteToken() => _storage.delete(key: _keyAccess);

  // --- User ID ---
  Future<void> saveUserId(String userId) => _storage.write(key: _keyUserId, value: userId);
  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  // --- Server URL ---
  Future<void> saveServerUrl(String url) => _storage.write(key: _keyServer, value: url);
  Future<String?> getServerUrl() => _storage.read(key: _keyServer);

  // --- Credentials (for automatic token refresh) ---
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
  }

  Future<String?> getUsername() => _storage.read(key: _keyUsername);
  Future<String?> getPassword() => _storage.read(key: _keyPassword);

  /// Delete all auth-related data (for logout).
  Future<void> clearAll() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyUserId);
    // Note: we keep the server URL so the user doesn't have to re-enter it.
  }
}