import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../profile/profile_service.dart';
import '../auth/auth_service.dart';

/// 백그라운드 메시지 핸들러 (top-level 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] 백그라운드 메시지 수신: ${message.notification?.title}');
}

/// FCM 푸시 알림 관련 초기화, 토큰 관리, 메시지 수신 처리
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _profileService = ProfileService();

  String? _currentToken;
  String? get currentToken => _currentToken;

  /// 앱 시작 시 호출 — 권한 요청 + 토큰 취득 + 리스너 등록
  Future<void> initialize() async {
    // 백그라운드 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 알림 권한 요청 (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] 권한 상태: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] 알림 권한 거부됨');
      return;
    }

    // 현재 토큰 취득 (iOS는 APNs 토큰이 아직 안 왔을 수 있으므로 실패 허용)
    try {
      _currentToken = await _messaging.getToken();
      debugPrint('[FCM] 토큰 취득: $_currentToken');
    } catch (e) {
      debugPrint('[FCM] 토큰 취득 실패 (나중에 재시도): $e');
    }

    // 토큰 갱신 리스너
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // 포그라운드 메시지 수신
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 백그라운드에서 알림 탭하여 앱 열었을 때
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 앱이 종료된 상태에서 알림 탭으로 열렸을 때
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// 로그인 후 서버에 토큰 등록
  Future<void> registerToken() async {
    _currentToken ??= await _messaging.getToken();
    if (_currentToken == null) return;

    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _profileService.registerDeviceToken(_currentToken!, platform: platform);
      debugPrint('[FCM] 서버에 토큰 등록 완료');
    } catch (e) {
      debugPrint('[FCM] 서버 토큰 등록 실패: $e');
    }
  }

  /// 로그아웃 시 서버에서 토큰 해제
  Future<void> unregisterToken() async {
    if (_currentToken == null) return;

    try {
      await _profileService.unregisterDeviceToken(_currentToken!);
      debugPrint('[FCM] 서버에서 토큰 해제 완료');
    } catch (e) {
      debugPrint('[FCM] 서버 토큰 해제 실패: $e');
    }
  }

  /// 토큰 갱신 시 서버에 재등록
  void _onTokenRefresh(String newToken) {
    debugPrint('[FCM] 토큰 갱신: $newToken');
    _currentToken = newToken;

    // 로그인 상태일 때만 서버에 등록
    AuthService().isLoggedIn().then((loggedIn) {
      if (loggedIn) registerToken();
    });
  }

  /// 포그라운드에서 메시지 수신
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] 포그라운드 메시지: ${message.notification?.title}');

    // iOS는 기본적으로 포그라운드에서 알림 표시 안 하므로 설정
    // Android는 자동 표시됨
    if (Platform.isIOS) {
      _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 알림 탭으로 앱 열었을 때 (네비게이션 처리)
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] 알림 탭으로 앱 열림: ${message.data}');
    // 추후 data payload에 따른 화면 이동 로직 추가 가능
  }
}
