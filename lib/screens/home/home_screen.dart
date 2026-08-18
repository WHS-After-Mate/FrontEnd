import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/home/home_service.dart';
import '../../services/home/home_models.dart';
import '../../services/mycare/mycare_service.dart';
import '../../services/mycare/mycare_models.dart';
import '../../services/profile/profile_service.dart';
import '../../services/profile/profile_models.dart';
import '../main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeService = HomeService();
  final _myCareService = MyCareService();
  final _profileService = ProfileService();

  HomeSummary? _summary;
  List<MembershipItem> _memberships = [];
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _homeService.getSummary(),
        _myCareService.getMemberships(),
        _profileService.getProfile(),
        _myCareService.getCareRecords(size: 1),
      ]);
      if (!mounted) return;
      final summary = results[0] as HomeSummary;
      // 배포 서버가 latestCare.brand를 아직 안 내려줄 수 있으므로 care-records에서 보완
      final recentRecords = results[3] as CareRecordList;
      if (summary.latestCare != null &&
          (summary.latestCare!.brand == null || summary.latestCare!.brand!.isEmpty) &&
          recentRecords.items.isNotEmpty) {
        summary.latestCare!.brand = recentRecords.items.first.brand;
      }
      setState(() {
        _summary = summary;
        _memberships = results[1] as List<MembershipItem>
          ..sort((a, b) => (b.lastUsedAt ?? '').compareTo(a.lastUsedAt ?? ''));
        _profile = results[2] as UserProfile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '데이터를 불러올 수 없습니다';
        _isLoading = false;
      });
    }
  }

  Color _getBrandColor(String? brand) {
    if (brand == null) return AppColors.whsBlack;
    final b = brand.toLowerCase();
    if (b.contains('amred') || b.contains('엠레드')) return AppColors.amred;
    if (b.contains('derna') || b.contains('더나')) return AppColors.derna;
    if (b.contains('wim') || b.contains('윔')) return AppColors.wim;
    return AppColors.whsBlack;
  }

  String _getBrandLabel(String? brand) {
    if (brand == null || brand.isEmpty) return '';
    final b = brand.toLowerCase();
    if (b.contains('amred')) return '엠레드';
    if (b.contains('derna')) return '더나';
    if (b.contains('wim')) return '윔';
    return brand;
  }

  @override
  Widget build(BuildContext context) {
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

    final summary = _summary!;
    final latestCare = summary.latestCare;
    final aftercare = summary.aftercareCard;
    final recommendation = summary.recommendation;
    final userName = _profile?.name ?? '';
    final userInitial = userName.isNotEmpty ? userName[0] : '';

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.whsBlack,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: date/greeting + avatar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestCare != null
                            ? '${DateTime.now().month}월 ${DateTime.now().day}일 · ${latestCare.careName} ${latestCare.daysElapsed}일차'
                            : '${DateTime.now().month}월 ${DateTime.now().day}일',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '안녕하세요, $userName님',
                        style: const TextStyle(
                          color: AppColors.whsBlack,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                AvatarCircle(initial: userInitial),
              ],
            ),
            const SizedBox(height: 20),

            // Today's care (animated gradient dark card)
            if (latestCare != null && aftercare != null)
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen(initialTab: 2)),
                  );
                },
                child: _AnimatedGradientCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ColorDot(color: _getBrandColor(latestCare.brand)),
                          const SizedBox(width: 8),
                          Text(
                            '${_getBrandLabel(latestCare.brand).isNotEmpty ? '${_getBrandLabel(latestCare.brand)} · ' : ''}오늘의 사후관리',
                            style: const TextStyle(color: Color(0xFFB8B8BC), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${latestCare.careName} · ${latestCare.daysElapsed}일차 케어',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '오늘 지켜야 할 점을 확인해보세요',
                        style: TextStyle(color: Color(0xFFB8B8BC), fontSize: 14),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'AI 가이드 보기 →',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (latestCare != null)
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen(initialTab: 2)),
                  );
                },
                child: _AnimatedGradientCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ColorDot(color: _getBrandColor(latestCare.brand)),
                          const SizedBox(width: 8),
                          Text(
                            '${_getBrandLabel(latestCare.brand).isNotEmpty ? '${_getBrandLabel(latestCare.brand)} · ' : ''}오늘의 사후관리',
                            style: const TextStyle(color: Color(0xFFB8B8BC), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${latestCare.careName} · ${latestCare.daysElapsed}일차',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '사후관리 가이드를 확인해보세요',
                        style: TextStyle(color: Color(0xFFB8B8BC), fontSize: 14),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'AI 가이드 보기 →',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),

            // Ask AI row
            WhiteCard(
              padding: const EdgeInsets.all(16),
              onTap: () => Navigator.pushNamed(context, '/ai-chat'),
              child: Row(
                children: [
                  const _ShimmerIcon(
                    icon: 'assets/svg/ic_ai_ask.svg',
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI에게 바로 물어보기',
                          style: TextStyle(
                            color: AppColors.whsBlack,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '궁금한 점을 챗봇에게 질문해보세요',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '>',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Next care recommendation
            if (recommendation != null) ...[
              const SectionTitle(text: '다음 관리 추천'),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/ai-recommend',
                  arguments: recommendation.recommendationId,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF3F0FF),
                        Color(0xFFFFFFFF),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFFE8E0F8), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 스파클 아이콘
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE7FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/svg/ic_sparkle.svg',
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // 텍스트
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation.careName,
                              style: const TextStyle(
                                color: AppColors.whsBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              recommendation.reasons.isNotEmpty
                                  ? recommendation.reasons.first
                                  : '',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '추천 상세 보기 →',
                              style: TextStyle(
                                color: AppColors.whsBlack,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Voucher status (개별 이용권 리스트)
            if (_memberships.isNotEmpty) ...[
              const SectionTitle(text: '이용권 현황'),
              WhiteCard(
                child: Column(
                  children: [
                    ..._memberships.asMap().entries.map((entry) {
                      final item = entry.value;
                      final isLast = entry.key == _memberships.length - 1;
                      final color = _getBrandColor(item.brand);
                      final brandLabel = _getBrandLabel(item.brand);
                      final displayName = brandLabel.isNotEmpty
                          ? '$brandLabel ${item.productName}'
                          : item.productName;
                      return Column(
                        children: [
                          _buildVoucherRow(
                            displayName,
                            item.remainingCount,
                            item.totalCount,
                            color,
                          ),
                          if (!isLast) const SizedBox(height: 18),
                        ],
                      );
                    }),
                    const SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainScreen(initialTab: 1, myCareTab: 2)),
                          );
                        },
                        child: const Text(
                          '전체 이용권 보기 >',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherRow(String name, int remaining, int total, Color color) {
    final used = total - remaining;
    return Column(
      children: [
        Row(
          children: [
            ColorDot(color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: AppColors.whsBlack, fontSize: 14),
              ),
            ),
            Text(
              '잔여 $remaining회',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: used / total),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.todayPillBg,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnimatedGradientCard extends StatefulWidget {
  final Widget child;
  const _AnimatedGradientCard({required this.child});

  @override
  State<_AnimatedGradientCard> createState() => _AnimatedGradientCardState();
}

class _AnimatedGradientCardState extends State<_AnimatedGradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
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
        final angle = _controller.value * 2 * pi;
        final dx = 0.5 * (1 + cos(angle));
        final dy = 0.5 * (1 + sin(angle));

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: RadialGradient(
              center: Alignment(-1.0 + 2.0 * dx, -1.0 + 2.0 * dy),
              radius: 1.5,
              colors: const [
                Color(0xFF1E1E3F),
                Color(0xFF12122A),
                Color(0xFF0A0A0B),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ShimmerIcon extends StatefulWidget {
  final String icon;
  final double size;
  const _ShimmerIcon({required this.icon, required this.size});

  @override
  State<_ShimmerIcon> createState() => _ShimmerIconState();
}

class _ShimmerIconState extends State<_ShimmerIcon>
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2.0 + 5.0 * _controller.value, -1.0 + 3.0 * _controller.value),
              end: Alignment(-0.5 + 5.0 * _controller.value, 1.0 + 3.0 * _controller.value),
              colors: [
                AppColors.whsBlack,
                AppColors.whsBlack.withValues(alpha: 0.7),
                AppColors.whsBlack.withValues(alpha: 0.85),
                AppColors.whsBlack,
              ],
              stops: const [0.0, 0.4, 0.6, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: SvgPicture.asset(
            widget.icon,
            width: widget.size,
            height: widget.size,
          ),
        );
      },
    );
  }
}
