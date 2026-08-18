import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

/// 토큰 저장/조회/삭제를 담당하는 매니저
class TokenManager {
  static final TokenManager _instance = TokenManager._();
  factory TokenManager() => _instance;
  TokenManager._();

  final _storage = const FlutterSecureStorage();

  Future<String?> getAccessToken() async {
    return await _storage.read(key: ApiConfig.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: ApiConfig.refreshTokenKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: ApiConfig.accessTokenKey, value: accessToken);
    await _storage.write(key: ApiConfig.refreshTokenKey, value: refreshToken);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: ApiConfig.accessTokenKey, value: accessToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: ApiConfig.accessTokenKey);
    await _storage.delete(key: ApiConfig.refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
