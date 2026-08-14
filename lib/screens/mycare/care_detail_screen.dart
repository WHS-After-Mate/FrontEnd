import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../main_screen.dart';
import '../aiguide/aiguide_detail_screen.dart';

class CareDetailScreen extends StatelessWidget {
  final String name;
  final String brand;
  final Color color;
  final String status;
  final String date;
  final String area;
  final int daysElapsed;
  final String session;
  final String voucher;
  final String manager;

  const CareDetailScreen({
    super.key,
    required this.name,
    required this.brand,
    required this.color,
    this.status = '완료',
    this.date = '7월 26일',
    this.area = '이중턱',
    this.daysElapsed = 19,
    this.session = '2/3회차',
    this.voucher = '3회 이용권',
    this.manager = '서진정 원장',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 1) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen(initialTab: i)),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/ic_home_outline.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/svg/ic_home_fill.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/ic_care_outline.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/svg/ic_care_fill.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            label: 'My Care',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/ic_ai_guide_outline.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/svg/ic_ai_guide_fill.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            label: 'AI 가이드',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/ic_settings_outline.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/svg/ic_settings_fill.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            label: '설정',
          ),
        ],
      ),
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
                    '관리 상세',
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 관리명
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.whsBlack,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 사업장 + 상태
                    Row(
                      children: [
                        ColorDot(color: color, size: 10),
                        const SizedBox(width: 8),
                        Text(
                          brand,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.todayPillBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 상세 정보 카드
                    WhiteCard(
                      child: Column(
                        children: [
                          _buildDetailRow('관리 일시', date),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildDetailRow('관리 부위', area),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildDetailRow('경과일', '관리 후 $daysElapsed일차'),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildDetailRow('관리 회차', session),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildDetailRow('이용권', voucher),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildDetailRow('담당자', manager),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: BlackButton(
                text: 'AI 사후관리 가이드 보기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiGuideDetailScreen(
                        careName: name,
                        brand: brand,
                        brandColor: color,
                        careDate: DateTime.now().subtract(Duration(days: daysElapsed)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: AppColors.whsBlack, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
