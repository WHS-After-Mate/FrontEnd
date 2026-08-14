import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AiGuideScreen extends StatefulWidget {
  const AiGuideScreen({super.key});

  @override
  State<AiGuideScreen> createState() => _AiGuideScreenState();
}

class _AiGuideScreenState extends State<AiGuideScreen> {
  // 가장 최근 관리 받은 날짜 (더미 - 나중에 API 연동)
  final DateTime _lastCareDate = DateTime.now().subtract(const Duration(days: 5));
  final String _careName = '울쎄라 리프팅';
  final String _brand = '엠레드';
  final Color _brandColor = AppColors.amred;

  // D+day 체크포인트 (관리 후 가이드가 제공되는 일수)
  final List<int> _checkpoints = [1, 3, 5, 7, 14];

  late int _todayDplus;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _todayDplus = DateTime.now().difference(_lastCareDate).inDays;
    // 오늘과 가장 가까운 checkpoint 선택
    _selectedIndex = _findClosestIndex();
  }

  int _findClosestIndex() {
    for (int i = 0; i < _checkpoints.length; i++) {
      if (_checkpoints[i] >= _todayDplus) return i;
    }
    return _checkpoints.length - 1;
  }

  String _getChipLabel(int checkpoint) {
    if (checkpoint < _todayDplus) return '완료';
    if (checkpoint == _todayDplus) return '오늘';
    return '예정';
  }

  // 더미 데이터 - 나중에 AI API로 교체
  final List<String> _careGuides = [
    '순한 저자극 스킨케어 제품 사용을 시작해도 좋아요.',
    '세안 시 미온수를 사용하고 부드럽게 톡톡 두드려 건조해주세요.',
    '자외선 차단제를 꼭 발라주세요 (SPF 50 이상 권장).',
  ];

  final List<String> _cautions = [
    '사우나, 찜질방 등 고온 환경은 피해주세요.',
    '음주는 회복을 늦출 수 있으니 자제해주세요.',
    '시술 부위를 강하게 문지르거나 자극하지 마세요.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 고정 헤더: 타이틀 + 사업장
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI 사후관리 가이드',
                style: TextStyle(
                  color: AppColors.whsBlack,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ColorDot(color: _brandColor, size: 8),
                  const SizedBox(width: 6),
                  Text(
                    '$_brand · $_careName',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // 스크롤 영역
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

          // Day chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_checkpoints.length, (i) {
                final checkpoint = _checkpoints[i];
                final selected = _selectedIndex == i;
                final label = _getChipLabel(checkpoint);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.whsBlack : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.whsBlack : AppColors.cardBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: selected ? AppColors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'D+$checkpoint',
                            style: TextStyle(
                              color: selected ? AppColors.white : AppColors.whsBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // 오늘의 핵심 케어 (다크 카드)
          DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/svg/ic_ai_ask.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '오늘의 핵심 케어',
                      style: TextStyle(color: AppColors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '회복기 중반이에요, 가벼운 스킨케어부터 서서히 시작해도 좋아요.',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),

          // 기본 사후관리 안내
          const Text(
            '기본 사후관리 안내',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ..._careGuides.map((guide) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildGuideItem(guide, isCheck: true),
              )),
          const SizedBox(height: 20),

          // 주의 사항 목록
          const Text(
            '주의 사항 목록',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ..._cautions.map((caution) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildGuideItem(caution, isCheck: false),
              )),
          const SizedBox(height: 20),

          // 더 궁금한 점 카드
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/ai-chat'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.whsBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/ic_question.svg',
                    width: 32,
                    height: 32,
                    colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '더 궁금한 점이 있나요?',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'AI 챗봇에게 바로 물어보세요',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('>', style: TextStyle(color: AppColors.white, fontSize: 18)),
                ],
              ),
            ),
          ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(String text, {required bool isCheck}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCheck ? AppColors.whsBlack : const Color(0xFFFF6B6B),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCheck ? Icons.check : Icons.priority_high,
              color: AppColors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.whsBlack, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
