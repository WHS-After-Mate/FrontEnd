import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'home_models.dart';

/// 홈 / 추천 관련 API 서비스
class HomeService {
  static final HomeService _instance = HomeService._();
  factory HomeService() => _instance;
  HomeService._();

  final _dio = ApiClient().dio;

  /// 홈 요약 조회
  Future<HomeSummary> getSummary() async {
    try {
      debugPrint('[HomeService] getSummary 호출');
      final response = await _dio.get('/home/summary');
      debugPrint('[HomeService] getSummary 성공');
      return HomeSummary.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[HomeService] getSummary 실패: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 다음 관리 추천 (단독 조회)
  Future<RecommendationDetail> getRecommendation() async {
    try {
      debugPrint('[HomeService] getRecommendation 호출');
      final response = await _dio.get('/recommendations/next-care');
      debugPrint('[HomeService] getRecommendation 성공');
      return RecommendationDetail.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[HomeService] getRecommendation 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 추천 상세 조회
  Future<RecommendationDetail> getRecommendationDetail(String recommendationId) async {
    try {
      debugPrint('[HomeService] getRecommendationDetail: $recommendationId');
      final response = await _dio.get('/recommendations/next-care/$recommendationId');
      debugPrint('[HomeService] getRecommendationDetail 성공');
      return RecommendationDetail.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[HomeService] getRecommendationDetail 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }
}
