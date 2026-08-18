import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/mycare/mycare_service.dart';
import '../../services/aftercare/aftercare_service.dart';
import '../../services/aftercare/aftercare_models.dart';

class AiGuideScreen extends StatefulWidget {
  final String? initialCareRecordId;
  const AiGuideScreen({super.key, this.initialCareRecordId});

  @override
  State<AiGuideScreen> createState() => _AiGuideScreenState();
}

class _AiGuideScreenState extends State<AiGuideScreen> {
  final _myCareService = MyCareService();
  final _aftercareService = AftercareService();

  DateTime? _lastCareDate;
  String _careRecordId = '';
  String _careName = '';
  String _brand = '';
  Color _brandColor = AppColors.whsBlack;
  bool _isLoading = true;
  bool _guideLoading = false;
  String? _error;

  // D+day 체크포인트 (관리 후 가이드가 제공되는 일수)
  final List<int> _checkpoints = [1, 3, 5, 7, 14];

  int _todayDplus = 0;
  int _selectedIndex = 0;

  // AI 가이드 데이터
  DailyGuide? _guide;

  @override
  void initState() {
    super.initState();
    _loadLatestCare();
  }

  Future<void> _loadLatestCare() async {
    try {
      final result = await _myCareService.getCareRecords(size: 10);
      if (!mounted) return;
      if (result.items.isNotEmpty) {
        // initialCareRecordId가 지정되었으면 해당 관리를 찾고, 없으면 최근 관리 사용
        final item = widget.initialCareRecordId != null
            ? result.items.firstWhere(
                (i) => i.careRecordId == widget.initialCareRecordId,
                orElse: () => result.items.first,
              )
            : result.items.first;
        setState(() {
          _lastCareDate = DateTime.parse(item.careDate);
          _careRecordId = item.careRecordId;
          _careName = item.careName;
          _brand = _brandLabel(item.brand);
          _brandColor = _getBrandColor(item.brand);
          _todayDplus = DateTime.now().difference(_lastCareDate!).inDays;
          _selectedIndex = _findClosestIndex();
        });
        // 최근 관리 정보 로드 후 가이드 호출
        await _loadGuide();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGuide() async {
    setState(() => _guideLoading = true);
    try {
      final selectedDay = _checkpoints[_selectedIndex];
      final guide = await _aftercareService.getDailyGuide(
        careRecordId: _careRecordId,
        elapsedDay: selectedDay,
      );
      if (!mounted) return;
      setState(() {
        _guide = guide;
        _guideLoading = false;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guideLoading = false;
        _isLoading = false;
        _error = '가이드를 불러올 수 없습니다';
      });
    }
  }

  String _brandLabel(String? brand) {
    if (brand == null || brand.isEmpty) return '';
    final b = brand.toUpperCase();
    if (b.contains('AMRED')) return '엠레드 클리닉';
    if (b.contains('DERNA')) return '더나 의원';
    if (b.contains('WIM')) return '윔 센터';
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

  int _findClosestIndex() {
    // 경과일 이하인 가장 큰 체크포인트를 기본 선택
    // 예: 11일차 → D+7(index 3), 14일차 → D+14(index 4)
    int result = 0;
    for (int i = 0; i < _checkpoints.length; i++) {
      if (_checkpoints[i] <= _todayDplus) {
        result = i;
      }
    }
    return result;
  }

  String _getChipLabel(int checkpoint) {
    // 현재 경과일이 이 체크포인트 구간에 해당하면 "오늘"
    final idx = _checkpoints.indexOf(checkpoint);
    final nextCheckpoint = idx < _checkpoints.length - 1 ? _checkpoints[idx + 1] : checkpoint + 1;
    if (_todayDplus >= checkpoint && _todayDplus < nextCheckpoint) return '오늘';
    if (checkpoint < _todayDplus) return '완료';
    return '예정';
  }

  String _buildSummaryMessage() {
    if (_guide == null) return '';
    final day = _checkpoints[_selectedIndex];
    if (day <= 1) {
      return '시술 직후예요. 자극을 최소화하고 안정을 취해주세요.';
    } else if (day <= 3) {
      return '초기 회복기예요. 시술 부위를 보호하고 주의사항을 지켜주세요.';
    } else if (day <= 5) {
      return '회복기 중반이에요. 가벼운 스킨케어부터 서서히 시작해도 좋아요.';
    } else if (day <= 7) {
      return '안정기에 접어들었어요. 기본 관리를 꾸준히 유지해주세요.';
    } else {
      return '일상 복귀 시기예요. 자외선 차단과 보습을 잊지 마세요.';
    }
  }

  void _onChipSelected(int index) {
    setState(() => _selectedIndex = index);
    _loadGuide();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.whsBlack));
    }

    if (_lastCareDate == null) {
      return const Center(
        child: Text('최근 관리 이력이 없습니다', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

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
          Row(
            children: List.generate(_checkpoints.length * 2 - 1, (i) {
              if (i.isOdd) return const SizedBox(width: 8);
              final index = i ~/ 2;
              final checkpoint = _checkpoints[index];
              final selected = _selectedIndex == index;
              final label = _getChipLabel(checkpoint);
              return Expanded(
                child: _DayChipButton(
                  selected: selected,
                  label: label,
                  day: 'D+$checkpoint',
                  onTap: () => _onChipSelected(index),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // 가이드 콘텐츠
          if (_guideLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: AppColors.whsBlack)),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else if (_guide != null) ...[
            // 오늘의 핵심 케어 (다크 카드)
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/ic_chat_smile_ai.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _guide!.isToday ? '오늘의 핵심 케어' : 'D+${_checkpoints[_selectedIndex]} 핵심 케어',
                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _buildSummaryMessage(),
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
            ..._guide!.basicCare.map((guide) => Padding(
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
            ..._guide!.mustAvoid.map((caution) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildGuideItem(caution, isCheck: false),
                )),
            const SizedBox(height: 20),
          ],

          // 더 궁금한 점 카드
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/ai-chat'),
            child: _ShimmerDarkCard(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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

class _DayChipButton extends StatefulWidget {
  final bool selected;
  final String label;
  final String day;
  final VoidCallback onTap;

  const _DayChipButton({
    required this.selected,
    required this.label,
    required this.day,
    required this.onTap,
  });

  @override
  State<_DayChipButton> createState() => _DayChipButtonState();
}

class _DayChipButtonState extends State<_DayChipButton> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: widget.selected ? AppColors.whsBlack : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.selected ? AppColors.whsBlack : AppColors.cardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.selected ? AppColors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.day,
                    style: TextStyle(
                      color: widget.selected ? AppColors.white : AppColors.whsBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerDarkCard extends StatefulWidget {
  final Widget child;
  const _ShimmerDarkCard({required this.child});

  @override
  State<_ShimmerDarkCard> createState() => _ShimmerDarkCardState();
}

class _ShimmerDarkCardState extends State<_ShimmerDarkCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.whsBlack,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(-3.0 + 6.0 * _controller.value, -1.0),
              end: Alignment(-1.5 + 6.0 * _controller.value, 1.0),
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.03),
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.03),
                Colors.transparent,
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
