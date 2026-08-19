import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'profile_models.dart';

/// 프로필/설정 관련 API 서비스
class ProfileService {
  static final ProfileService _instance = ProfileService._();
  factory ProfileService() => _instance;
  ProfileService._();

  final _dio = ApiClient().dio;

  /// 프로필 조회
  Future<UserProfile> getProfile() async {
    try {
      debugPrint('[ProfileService] getProfile 호출');
      final response = await _dio.get('/profile');
      debugPrint('[ProfileService] getProfile 성공');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[ProfileService] getProfile 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 프로필 수정 (이름, 생년월일)
  Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
    try {
      debugPrint('[ProfileService] updateProfile: ${request.toJson()}');
      final response = await _dio.patch('/profile', data: request.toJson());
      debugPrint('[ProfileService] updateProfile 성공');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[ProfileService] updateProfile 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 비밀번호 변경
  Future<void> changePassword(PasswordChangeRequest request) async {
    try {
      debugPrint('[ProfileService] changePassword 호출');
      await _dio.post('/profile/password', data: request.toJson());
      debugPrint('[ProfileService] changePassword 성공');
    } on DioException catch (e) {
      debugPrint('[ProfileService] changePassword 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 관심 목표 설정
  Future<List<String>> updateInterests(InterestsUpdateRequest request) async {
    try {
      debugPrint('[ProfileService] updateInterests: ${request.goals}');
      final response = await _dio.put('/profile/interests', data: request.toJson());
      debugPrint('[ProfileService] updateInterests 성공');
      return List<String>.from(response.data['interestGoals'] ?? []);
    } on DioException catch (e) {
      debugPrint('[ProfileService] updateInterests 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 알림 설정 조회
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      debugPrint('[ProfileService] getNotificationSettings 호출');
      final response = await _dio.get('/profile/notifications');
      debugPrint('[ProfileService] getNotificationSettings 성공');
      return NotificationSettings.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[ProfileService] getNotificationSettings 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 알림 설정 변경
  Future<NotificationSettings> updateNotificationSettings(NotificationSettingsUpdate request) async {
    try {
      debugPrint('[ProfileService] updateNotificationSettings: ${request.toJson()}');
      final response = await _dio.patch('/profile/notifications', data: request.toJson());
      debugPrint('[ProfileService] updateNotificationSettings 성공');
      return NotificationSettings.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[ProfileService] updateNotificationSettings 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// FCM 토큰 등록
  Future<void> registerDeviceToken(String fcmToken, {String platform = 'android'}) async {
    try {
      debugPrint('[ProfileService] registerDeviceToken');
      await _dio.post('/notifications/device-token', data: {
        'fcmToken': fcmToken,
        'platform': platform,
      });
      debugPrint('[ProfileService] registerDeviceToken 성공');
    } on DioException catch (e) {
      debugPrint('[ProfileService] registerDeviceToken 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// FCM 토큰 해제
  Future<void> unregisterDeviceToken(String fcmToken) async {
    try {
      debugPrint('[ProfileService] unregisterDeviceToken');
      await _dio.delete('/notifications/device-token', data: {
        'fcmToken': fcmToken,
      });
      debugPrint('[ProfileService] unregisterDeviceToken 성공');
    } on DioException catch (e) {
      debugPrint('[ProfileService] unregisterDeviceToken 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }
}
