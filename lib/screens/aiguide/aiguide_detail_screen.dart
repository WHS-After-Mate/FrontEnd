import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AiGuideDetailScreen extends StatefulWidget {
  final String careName;
  final String brand;
  final Color brandColor;
  final DateTime careDate;

  const AiGuideDetailScreen({
    super.key,
    required this.careName,
    required this.brand,
    required this.brandColor,
    required this.careDate,
  });

  @override
  State<AiGuideDetailScreen> createState() => _AiGuideDetailScreenState();
}

class _AiGuideDetailScreenState extends State<AiGuideDetailScreen> {
  final List<int> _checkpoints = [1, 3, 5, 7, 14];
  late int _todayDplus;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _todayDplus = DateTime.now().difference(widget.careDate).inDays;
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

  // 더미 데이터 - 나중에 AI API로 교체 (관리별로 다른 내용)
  List<String> get _careGuides {
    return [
      '순한 저자극 스킨케어 제품 사용을 시작해도 좋아요.',
      '세안 시 미온수를 사용하고 부드럽게 톡톡 두드려 건조해주세요.',
      '자외선 차단제를 꼭 발라주세요 (SPF 50 이상 권장).',
    ];
  }

  List<String> get _cautions {
    return [
      '사우나, 찜질방 등 고온 환경은 피해주세요.',
      '음주는 회복을 늦출 수 있으니 자제해주세요.',
      '시술 부위를 강하게 문지르거나 자극하지 마세요.',
    ];
  }

  String get _coreMessage {
    if (_todayDplus <= 1) return '시술 직후예요. 시술 부위를 만지지 말고 충분히 휴식하세요.';
    if (_todayDplus <= 3) return '초기 회복기예요. 세안 시 자극을 최소화해주세요.';
    if (_todayDplus <= 5) return '회복기 중반이에요, 가벼운 스킨케어부터 서서히 시작해도 좋아요.';
    if (_todayDplus <= 7) return '회복이 잘 진행되고 있어요. 보습에 신경 써주세요.';
    return '거의 회복됐어요! 일상으로 돌아가되 자극은 피해주세요.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.whsBlack),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI 사후관리 가이드',
                    style: TextStyle(
                      color: AppColors.whsBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사업장 · 관리명
                    Row(
                      children: [
                        ColorDot(color: widget.brandColor, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.brand} · ${widget.careName}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

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

                    // 오늘의 핵심 케어
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
                          Text(
                            _coreMessage,
                            style: const TextStyle(
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

                    // 더 궁금한 점
                    GestureDetector(
                      onTap: () {},
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
        ),
      ),
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
