import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'aftercare_models.dart';

/// 사후관리 안내 및 Q&A API 서비스
class AftercareService {
  static final AftercareService _instance = AftercareService._();
  factory AftercareService() => _instance;
  AftercareService._();

  final _dio = ApiClient().dio;

  /// 일차별 사후관리 가이드 조회
  Future<DailyGuide> getDailyGuide({String? careRecordId, int? elapsedDay}) async {
    try {
      final params = <String, dynamic>{};
      if (careRecordId != null) params['careRecordId'] = careRecordId;
      if (elapsedDay != null) params['elapsedDay'] = elapsedDay;

      debugPrint('[AftercareService] getDailyGuide: $params');
      final response = await _dio.get('/aftercare/daily-guide', queryParameters: params);
      debugPrint('[AftercareService] getDailyGuide 성공');
      return DailyGuide.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AftercareService] getDailyGuide 실패: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 질문 카테고리 목록 조회
  Future<QuestionCategories> getQuestionCategories() async {
    try {
      debugPrint('[AftercareService] getQuestionCategories 호출');
      final response = await _dio.get('/aftercare/question-categories');
      debugPrint('[AftercareService] getQuestionCategories 성공');
      return QuestionCategories.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AftercareService] getQuestionCategories 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 질문 등록 → LLM 답변
  Future<QuestionResponse> askQuestion(QuestionRequest request) async {
    try {
      debugPrint('[AftercareService] askQuestion: ${request.category} - ${request.question}');
      final response = await _dio.post('/aftercare/questions', data: request.toJson());
      debugPrint('[AftercareService] askQuestion 성공: status=${response.data['status']}');
      return QuestionResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AftercareService] askQuestion 실패: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 내 질문 이력 조회
  Future<List<QuestionHistoryItem>> getQuestionHistory() async {
    try {
      debugPrint('[AftercareService] getQuestionHistory 호출');
      final response = await _dio.get('/aftercare/questions');
      final items = (response.data['items'] as List<dynamic>)
          .map((e) => QuestionHistoryItem.fromJson(e))
          .toList();
      debugPrint('[AftercareService] getQuestionHistory 성공: ${items.length}건');
      return items;
    } on DioException catch (e) {
      debugPrint('[AftercareService] getQuestionHistory 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }
}
