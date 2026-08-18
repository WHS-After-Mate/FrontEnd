import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/token_manager.dart';
import 'auth_models.dart';

/// 인증 관련 API 서비스
class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final _dio = ApiClient().dio;
  final _tokenManager = TokenManager();

  /// 로그인
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      debugPrint('[AuthService] login: ${request.email}');
      final response = await _dio.post('/auth/login', data: request.toJson());
      final authResponse = AuthResponse.fromJson(response.data);
      await _tokenManager.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      debugPrint('[AuthService] login 성공: userId=${authResponse.user.id}');
      return authResponse;
    } on DioException catch (e) {
      debugPrint('[AuthService] login 실패: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 회원가입 pre-check: 환자번호+이름+생년월일+전화번호 일치 여부만 서버에서 확인
  Future<void> signupPreCheck({
    required String patientNo,
    required String name,
    required String birthDate,
    required String phone,
  }) async {
    try {
      debugPrint('[AuthService] signupPreCheck: patientNo=$patientNo, name=$name');
      await _dio.post('/auth/signup/pre-check', data: {
        'patientNo': patientNo,
        'name': name,
        'birthDate': birthDate,
        'phone': phone,
      });
      debugPrint('[AuthService] signupPreCheck 통과');
    } on DioException catch (e) {
      debugPrint('[AuthService] signupPreCheck 실패: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 회원가입
  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      debugPrint('[AuthService] signup: patientNo=${request.patientNo}, name=${request.name}');
      final response = await _dio.post('/auth/signup', data: request.toJson());
      final authResponse = AuthResponse.fromJson(response.data);
      await _tokenManager.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      debugPrint('[AuthService] signup 성공: userId=${authResponse.user.id}');
      return authResponse;
    } on DioException catch (e) {
      debugPrint('[AuthService] signup 실패: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 토큰 갱신
  Future<String> refresh() async {
    try {
      debugPrint('[AuthService] refresh 시도');
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw ApiException(code: 'NO_REFRESH_TOKEN', message: '로그인이 필요합니다');
      }
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      final newAccessToken = response.data['accessToken'] as String;
      await _tokenManager.updateAccessToken(newAccessToken);
      debugPrint('[AuthService] refresh 성공');
      return newAccessToken;
    } on DioException catch (e) {
      debugPrint('[AuthService] refresh 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    debugPrint('[AuthService] logout');
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (_) {
      // 로그아웃 실패해도 로컬 토큰은 삭제
    } finally {
      await _tokenManager.clearTokens();
      debugPrint('[AuthService] 토큰 삭제 완료');
    }
  }

  /// 비밀번호 재설정 1단계: 이메일 인증코드 발송
  Future<void> requestPasswordReset(PasswordResetRequest request) async {
    try {
      debugPrint('[AuthService] password reset-request: ${request.email}');
      await _dio.post('/auth/password/reset-request', data: request.toJson());
      debugPrint('[AuthService] password reset-request 완료');
    } on DioException catch (e) {
      debugPrint('[AuthService] password reset-request 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 비밀번호 재설정 2단계: 인증코드 확인 → resetToken 발급
  Future<PasswordResetVerifyResponse> verifyPasswordReset(PasswordResetVerify request) async {
    try {
      debugPrint('[AuthService] password reset-verify: ${request.email}');
      final response = await _dio.post('/auth/password/reset-verify', data: request.toJson());
      debugPrint('[AuthService] password reset-verify 성공');
      return PasswordResetVerifyResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AuthService] password reset-verify 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 비밀번호 재설정 3단계: 새 비밀번호 확정
  Future<void> confirmPasswordReset(PasswordResetConfirm request) async {
    try {
      debugPrint('[AuthService] password reset-confirm');
      await _dio.post('/auth/password/reset-confirm', data: request.toJson());
      debugPrint('[AuthService] password reset-confirm 성공');
    } on DioException catch (e) {
      debugPrint('[AuthService] password reset-confirm 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    return await _tokenManager.hasTokens();
  }
}
