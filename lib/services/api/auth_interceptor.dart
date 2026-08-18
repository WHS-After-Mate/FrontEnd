import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'token_manager.dart';
import 'api_config.dart';
import '../../main.dart' show navigatorKey;

/// 인증 인터셉터
/// - 요청 시 accessToken을 헤더에 자동 추가
/// - 401 응답 시 refreshToken으로 토큰 갱신 후 재시도
/// - refresh도 실패하면 로그인 화면으로 이동
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenManager _tokenManager;
  bool _isRefreshing = false;

  AuthInterceptor(this._dio, this._tokenManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // /auth/ 경로는 토큰 불필요 (login, signup, refresh 등)
    final isAuthPath = options.path.contains('/auth/');
    if (!isAuthPath) {
      final token = await _tokenManager.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      // refresh 요청 자체가 401이면 더 이상 재시도하지 않음
      if (err.requestOptions.path.contains('/auth/refresh')) {
        await _tokenManager.clearTokens();
        _redirectToLogin();
        handler.next(err);
        return;
      }

      _isRefreshing = true;
      try {
        final refreshToken = await _tokenManager.getRefreshToken();
        if (refreshToken == null) {
          await _tokenManager.clearTokens();
          _redirectToLogin();
          handler.next(err);
          return;
        }

        // refresh 요청
        final response = await Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
        )).post('/auth/refresh', data: {'refreshToken': refreshToken});

        final newAccessToken = response.data['accessToken'] as String;
        await _tokenManager.updateAccessToken(newAccessToken);

        // 원래 요청 재시도
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(opts);
        handler.resolve(retryResponse);
      } catch (_) {
        await _tokenManager.clearTokens();
        _redirectToLogin();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  void _redirectToLogin() {
    debugPrint('[AuthInterceptor] 세션 만료 — 로그인 화면으로 이동');
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
}
