/// API 설정 상수
class ApiConfig {
  ApiConfig._();

  /// 백엔드 Base URL (개발 환경)
  /// Android 에뮬레이터: 10.0.2.2, iOS 시뮬레이터/실기기: localhost 또는 실제 IP
  static const String baseUrl = 'http://1.201.116.115/api/v1';

  /// 요청 타임아웃 (초)
  static const int connectTimeout = 10;
  static const int receiveTimeout = 30;

  /// 토큰 저장소 키
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
