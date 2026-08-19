import 'package:flutter/foundation.dart';
import 'home_models.dart';
import 'home_service.dart';
import '../mycare/mycare_service.dart';
import '../mycare/mycare_models.dart';
import '../profile/profile_service.dart';
import '../profile/profile_models.dart';

/// 홈 화면 데이터를 캐싱하여 불필요한 API/AI 호출을 방지하는 싱글톤 컨트롤러.
///
/// 캐시 무효화 조건:
/// - 시술 이력 추가/변경
/// - 관심 목표 변경
/// - 사용자가 수동으로 새로고침 (pull-to-refresh)
class HomeCache extends ChangeNotifier {
  static final HomeCache _instance = HomeCache._();
  factory HomeCache() => _instance;
  HomeCache._();

  final _homeService = HomeService();
  final _myCareService = MyCareService();
  final _profileService = ProfileService();

  // 캐시된 데이터
  HomeSummary? _summary;
  List<MembershipItem>? _memberships;
  UserProfile? _profile;

  // 상태
  bool _isLoading = false;
  String? _error;
  bool _hasData = false;

  HomeSummary? get summary => _summary;
  List<MembershipItem>? get memberships => _memberships;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _hasData;

  /// 캐시된 데이터가 있으면 그대로 반환, 없으면 로드.
  Future<void> loadIfNeeded() async {
    if (_hasData) return;
    await reload();
  }

  /// 강제 리로드 (pull-to-refresh 또는 캐시 무효화 후).
  Future<void> reload() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _homeService.getSummary(),
        _myCareService.getMemberships(),
        _profileService.getProfile(),
        _myCareService.getCareRecords(size: 1),
      ]);

      final summary = results[0] as HomeSummary;
      final recentRecords = results[3] as CareRecordList;

      // 배포 서버가 latestCare.brand를 아직 안 내려줄 수 있으므로 care-records에서 보완
      if (summary.latestCare != null &&
          (summary.latestCare!.brand == null || summary.latestCare!.brand!.isEmpty) &&
          recentRecords.items.isNotEmpty) {
        summary.latestCare!.brand = recentRecords.items.first.brand;
      }

      _summary = summary;
      _memberships = (results[1] as List<MembershipItem>)
        ..sort((a, b) => (b.lastUsedAt ?? '').compareTo(a.lastUsedAt ?? ''));
      _profile = results[2] as UserProfile;
      _hasData = true;
      _error = null;
    } catch (e) {
      debugPrint('[HomeCache] reload 실패: $e');
      _error = '데이터를 불러올 수 없습니다';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 캐시 무효화 - 다음 홈 진입 시 리로드됨.
  void invalidate() {
    debugPrint('[HomeCache] 캐시 무효화');
    _hasData = false;
  }
}
