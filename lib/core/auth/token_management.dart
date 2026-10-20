import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopsphere/core/auth/token_pair.dart';

class TokenManagement {
  TokenManagement._();
  static final TokenManagement instance = TokenManagement._();
  static const _storage = FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> saveTokens(TokenPair pair) async {
    await _storage.write(key: _accessKey, value: pair.accessToken);
    await _storage.write(key: _refreshKey, value: pair.refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
