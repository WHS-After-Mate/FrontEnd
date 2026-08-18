import 'package:dio/dio.dart';

/// API 에러 응답을 파싱한 예외 클래스
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  /// DioException에서 ApiException을 추출
  factory ApiException.fromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('error')) {
      final error = data['error'] as Map<String, dynamic>;
      return ApiException(
        code: error['code'] ?? 'UNKNOWN_ERROR',
        message: error['message'] ?? '알 수 없는 오류가 발생했습니다',
        statusCode: e.response?.statusCode,
      );
    }

    // 네트워크 오류 등 서버 응답이 없는 경우
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        code: 'TIMEOUT',
        message: '서버 응답 시간이 초과되었습니다',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        code: 'CONNECTION_ERROR',
        message: '서버에 연결할 수 없습니다',
      );
    }

    return ApiException(
      code: 'UNKNOWN_ERROR',
      message: e.message ?? '알 수 없는 오류가 발생했습니다',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => 'ApiException($code): $message';
}
