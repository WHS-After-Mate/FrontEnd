import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/aftercare/aftercare_service.dart';
import '../../services/aftercare/aftercare_models.dart';
import '../../services/api/api_exception.dart';

class AiGuideDetailScreen extends StatefulWidget {
  final String careName;
  final String brand;
  final Color brandColor;
  final DateTime careDate;
  final String? careRecordId;

  const AiGuideDetailScreen({
    super.key,
    required this.careName,
    required this.brand,
    required this.brandColor,
    required this.careDate,
    this.careRecordId,
  });

  @override
  State<AiGuideDetailScreen> createState() => _AiGuideDetailScreenState();
}

class _AiGuideDetailScreenState extends State<AiGuideDetailScreen> {
  final _aftercareService = AftercareService();
  final List<int> _checkpoints = [1, 3, 5, 7, 14];
  late int _todayDplus;
  late int _selectedIndex;

  DailyGuide? _guide;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _todayDplus = DateTime.now().difference(widget.careDate).inDays;
    _selectedIndex = _findClosestIndex();
    _loadGuide();
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

  Future<void> _loadGuide() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final guide = await _aftercareService.getDailyGuide(
        careRecordId: widget.careRecordId,
        elapsedDay: _checkpoints[_selectedIndex],
      );
      if (!mounted) return;
      setState(() {
        _guide = guide;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = (e.statusCode == 404 || e.code == 'GUIDE_NOT_AVAILABLE')
            ? '해당 일차의 가이드가 아직 준비되지 않았어요'
            : '가이드를 불러올 수 없습니다';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '가이드를 불러올 수 없습니다';
        _isLoading = false;
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
    _loadGuide();
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
                              onTap: () => _onTabChanged(i),
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

                    // Content
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator(color: AppColors.whsBlack)),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: [
              Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _loadGuide,
                child: const Text('다시 시도', style: TextStyle(color: AppColors.whsBlack, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final guide = _guide!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  Text(
                    guide.isToday ? '오늘의 핵심 케어' : 'D+${guide.daysElapsed} 케어 안내',
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                guide.keyCare != null && guide.keyCare!.isNotEmpty && !guide.keyCare!.contains('확인해주세요')
                    ? guide.keyCare!
                    : guide.aftercare.isNotEmpty
                        ? guide.aftercare.first
                        : '${guide.careName} ${guide.daysElapsed}일차 케어 안내입니다.',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              if (!guide.isToday) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '시술별 맞춤 가이드',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 26),

        // 기본 사후관리 안내
        if (guide.aftercare.isNotEmpty) ...[
          const Text(
            '기본 사후관리 안내',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...guide.aftercare.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildGuideItem(item, isCheck: true),
          )),
          const SizedBox(height: 20),
        ],

        // 주의 사항 목록
        if (guide.precautions.isNotEmpty) ...[
          const Text(
            '주의 사항 목록',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...guide.precautions.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildGuideItem(item, isCheck: false),
          )),
          const SizedBox(height: 20),
        ],

        // 더 궁금한 점
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
