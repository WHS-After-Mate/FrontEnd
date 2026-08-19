import 'package:flutter/foundation.dart';
import 'home_models.dart';
import 'home_service.dart';
import '../profile/profile_service.dart';
import '../profile/profile_models.dart';

/// AI 관리 추천 데이터를 캐싱하여 불필요한 AI 토큰 사용을 방지하는 싱글톤 컨트롤러.
///
/// 캐시 무효화 조건:
/// - 이용권 추가/변경
/// - 관심 목표 변경
/// - 사용자가 수동으로 새로고침
class RecommendCache extends ChangeNotifier {
  static final RecommendCache _instance = RecommendCache._();
  factory RecommendCache() => _instance;
  RecommendCache._();

  final _homeService = HomeService();
  final _profileService = ProfileService();

  // 캐시된 데이터
  // key: recommendationId (또는 'latest' for 기본 추천)
  final Map<String, RecommendationDetail> _detailCache = {};
  UserProfile? _profile;

  // 상태
  bool _isLoading = false;
  String? _error;

  RecommendationDetail? get latestDetail => _detailCache['latest'];
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _detailCache.containsKey('latest');

  /// ID로 캐시된 추천 상세 조회
  RecommendationDetail? getDetail(String id) => _detailCache[id];

  /// 캐시가 있으면 그대로, 없으면 로드.
  Future<void> loadIfNeeded({String? recommendationId}) async {
    final key = recommendationId ?? 'latest';
    if (_detailCache.containsKey(key)) return;
    await reload(recommendationId: recommendationId);
  }

  /// 강제 리로드.
  Future<void> reload({String? recommendationId}) async {
    final key = recommendationId ?? 'latest';
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 프로필 로드
      try {
        _profile = await _profileService.getProfile();
      } catch (_) {}

      RecommendationDetail detail;
      if (recommendationId != null && recommendationId.isNotEmpty) {
        detail = await _homeService.getRecommendationDetail(recommendationId);
      } else {
        detail = await _homeService.getRecommendation();
      }

      _detailCache[key] = detail;
      // 'latest'가 아닌 경우에도 ID로 저장
      if (key == 'latest') {
        _detailCache[detail.recommendationId] = detail;
      }
      _error = null;
    } catch (e) {
      debugPrint('[RecommendCache] reload 실패: $e');
      _error = '추천 정보를 불러올 수 없습니다';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 캐시 무효화 - 다음 진입 시 리로드됨.
  void invalidate() {
    debugPrint('[RecommendCache] 캐시 무효화');
    _detailCache.clear();
  }
}
