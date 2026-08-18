import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/home/home_service.dart';
import '../../services/home/home_models.dart';
import '../../services/profile/profile_service.dart';
import '../../services/profile/profile_models.dart';
import '../../utils/toast.dart';
import '../main_screen.dart';

class AiRecommendScreen extends StatefulWidget {
  const AiRecommendScreen({super.key});

  @override
  State<AiRecommendScreen> createState() => _AiRecommendScreenState();
}

class _AiRecommendScreenState extends State<AiRecommendScreen> {
  final _homeService = HomeService();
  final _profileService = ProfileService();
  RecommendationDetail? _detail;
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  /// 추천 이유에서 관심 목표 태그를 추출
  List<String> get _matchedGoals {
    if (_detail == null) return [];
    // reasons에서 "관심 목표(X, Y)에 도움이 돼요" 패턴에서 태그 추출
    for (final reason in _detail!.reasons) {
      final match = RegExp(r'관심 목표\((.+?)\)').firstMatch(reason);
      if (match != null) {
        return match.group(1)!.split(', ').map((s) => s.trim()).toList();
      }
    }
    // 추출 실패 시 프로필 관심목표 표시
    return _profile?.interestGoals ?? [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_detail == null && _isLoading) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // context를 async gap 이전에 읽어둠
    final args = ModalRoute.of(context)?.settings.arguments;

    try {
      // 프로필 로드
      try {
        _profile = await _profileService.getProfile();
      } catch (_) {}

      RecommendationDetail detail;
      if (args is String && args.isNotEmpty) {
        detail = await _homeService.getRecommendationDetail(args);
      } else {
        detail = await _homeService.getRecommendation();
      }
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '추천 정보를 불러올 수 없습니다';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 72,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.whsBlack),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '관리 추천',
                          style: TextStyle(
                            color: AppColors.whsBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),

            // 플로팅 네비게이션 바
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavBar(
                currentIndex: 0,
                onTap: (i) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen(initialTab: i)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.whsBlack));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _loadData,
              child: const Text('다시 시도', style: TextStyle(color: AppColors.whsBlack, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    final detail = _detail!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            '${_profile?.name ?? ''}님을 위한\n관리 추천',
            style: const TextStyle(
              color: AppColors.whsBlack,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '선택한 고민과 최근 관리 이력을 분석했어요',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // 관심 목표 칩 (추천과 연결된 목표만)
          if (_matchedGoals.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _matchedGoals.map((goal) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.whsBlack,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(goal, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),

          // Best recommendation (dark card)
          DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '가장 추천하는 관리',
                  style: TextStyle(color: Color(0xFFB8B8BC), fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  detail.careName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (detail.clinicContacts.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${detail.clinicContacts.first.label} · 권장 시점 2~3주 후',
                    style: const TextStyle(color: Color(0xFFB8B8BC), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          // 최근 관리 기준 표시
          if (detail.relatedRecentCares.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '최근 관리: ${detail.relatedRecentCares.first.careName} · ${detail.relatedRecentCares.first.daysElapsed}일 전',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Reasons
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              '이 관리를 추천한 이유',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...detail.reasons.map((reason) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: WhiteCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SvgPicture.asset('assets/svg/ic_check.svg', width: 16, height: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(color: AppColors.whsBlack, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )),

          // Related recent cares
          if (detail.relatedRecentCares.isNotEmpty) ...[
            const SectionTitle(text: '최근 관리와 함께 확인했어요'),
            WhiteCard(
              child: Column(
                children: detail.relatedRecentCares.asMap().entries.map((entry) {
                  final care = entry.value;
                  final isLast = entry.key == detail.relatedRecentCares.length - 1;
                  final brandColor = _getBrandColor(care.brand);
                  final brandName = _brandLabelShort(care.brand);
                  return Column(
                    children: [
                      Row(
                        children: [
                          ColorDot(color: brandColor, size: 10),
                          const SizedBox(width: 10),
                          Text(
                            care.careName,
                            style: const TextStyle(color: AppColors.whsBlack, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          if (brandName.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '· $brandName',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                          const Spacer(),
                          Text('${care.daysElapsed}일 경과', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                      if (!isLast) const Divider(height: 20, color: AppColors.divider),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],

          // 이런 고민에 적합해요
          if (detail.categoryTags.isNotEmpty) ...[
            const SectionTitle(text: '이런 고민에 적합해요'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail.categoryTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(tag, style: const TextStyle(color: AppColors.whsBlack, fontSize: 13)),
                );
              }).toList(),
            ),
          ],

          // 상담하기
          if (detail.clinicContacts.isNotEmpty) ...[
            const SectionTitle(text: '상담하기'),
            Row(
              children: [
                // 카톡 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final url = detail.clinicContacts.first.talkChannelUrl;
                      if (url != null && url.isNotEmpty) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        showToast('카톡 상담 링크가 아직 등록되지 않았어요');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.whsBlack,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/svg/ic_kakao.svg', width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn)),
                          const SizedBox(width: 6),
                          Text(
                            '${detail.clinicContacts.first.label} 카톡',
                            style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 전화 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final phone = detail.clinicContacts.first.phone;
                      if (phone != null && phone.isNotEmpty) {
                        final uri = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          showToast('전화: $phone');
                        }
                      } else {
                        showToast('전화번호가 아직 등록되지 않았어요');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.whsBlack,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/svg/ic_call.svg', width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn)),
                          const SizedBox(width: 6),
                          Text(
                            '${detail.clinicContacts.first.label} 전화',
                            style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Disclaimer
          if (detail.disclaimer.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              detail.disclaimer,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  String _brandLabelShort(String? brand) {
    if (brand == null || brand.isEmpty) return '';
    final b = brand.toUpperCase();
    if (b.contains('AMRED')) return '엠레드';
    if (b.contains('DERNA')) return '더나';
    if (b.contains('WIM')) return '윔';
    return brand;
  }

  Color _getBrandColor(String? brand) {
    if (brand == null) return AppColors.whsBlack;
    final b = brand.toUpperCase();
    if (b.contains('AMRED')) return AppColors.amred;
    if (b.contains('DERNA')) return AppColors.derna;
    if (b.contains('WIM')) return AppColors.wim;
    return AppColors.whsBlack;
  }
}
