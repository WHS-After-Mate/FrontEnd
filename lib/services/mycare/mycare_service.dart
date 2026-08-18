import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'mycare_models.dart';

/// My Care 관련 API 서비스
class MyCareService {
  static final MyCareService _instance = MyCareService._();
  factory MyCareService() => _instance;
  MyCareService._();

  final _dio = ApiClient().dio;

  /// 캘린더 월별 마커 조회
  Future<CareCalendar> getCalendar(String month) async {
    try {
      debugPrint('[MyCareService] getCalendar: $month');
      final response = await _dio.get('/care-records/calendar', queryParameters: {'month': month});
      debugPrint('[MyCareService] getCalendar 성공');
      return CareCalendar.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[MyCareService] getCalendar 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 관리 이력 목록 조회
  Future<CareRecordList> getCareRecords({
    int page = 1,
    int size = 20,
    String? dateFrom,
    String? dateTo,
    String? brand,
    String? partOfBody,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (dateFrom != null) params['dateFrom'] = dateFrom;
      if (dateTo != null) params['dateTo'] = dateTo;
      if (brand != null) params['brand'] = brand;
      if (partOfBody != null) params['partOfBody'] = partOfBody;

      debugPrint('[MyCareService] getCareRecords: $params');
      final response = await _dio.get('/care-records', queryParameters: params);
      debugPrint('[MyCareService] getCareRecords 성공: ${response.data['totalCount']}건');
      return CareRecordList.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[MyCareService] getCareRecords 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 관리 상세 조회
  Future<CareRecordDetail> getCareRecordDetail(String careRecordId) async {
    try {
      debugPrint('[MyCareService] getCareRecordDetail: $careRecordId');
      final response = await _dio.get('/care-records/$careRecordId');
      debugPrint('[MyCareService] getCareRecordDetail 성공');
      return CareRecordDetail.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[MyCareService] getCareRecordDetail 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 이용권 목록 조회
  Future<List<MembershipItem>> getMemberships() async {
    try {
      debugPrint('[MyCareService] getMemberships 호출');
      final response = await _dio.get('/memberships');
      final items = (response.data['items'] as List<dynamic>)
          .map((e) => MembershipItem.fromJson(e))
          .toList();
      debugPrint('[MyCareService] getMemberships 성공: ${items.length}건');
      return items;
    } on DioException catch (e) {
      debugPrint('[MyCareService] getMemberships 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }

  /// 이용권 상세 조회
  Future<MembershipItem> getMembershipDetail(String membershipId) async {
    try {
      debugPrint('[MyCareService] getMembershipDetail: $membershipId');
      final response = await _dio.get('/memberships/$membershipId');
      debugPrint('[MyCareService] getMembershipDetail 성공');
      return MembershipItem.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[MyCareService] getMembershipDetail 실패: ${e.response?.statusCode}');
      throw ApiException.fromDioException(e);
    }
  }
}
