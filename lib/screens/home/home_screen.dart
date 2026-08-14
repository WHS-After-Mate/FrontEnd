import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../main_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      '${DateTime.now().month}월 ${DateTime.now().day}일 · 울쎄라 리프팅 5일차',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '안녕하세요, 지수님',
                      style: TextStyle(
                        color: AppColors.whsBlack,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const AvatarCircle(initial: '지'),
            ],
          ),
          const SizedBox(height: 20),

          // Today's care (dark card)
          DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    ColorDot(color: AppColors.amred),
                    SizedBox(width: 8),
                    Text(
                      '엠레드 · 오늘의 사후관리',
                      style: TextStyle(color: AppColors.white, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '울쎄라 리프팅 · 5일차 케어',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '회복기 중반, 오늘 지켜야 할 점을 확인해보세요',
                  style: TextStyle(color: Color(0xFFB8B8BC), fontSize: 14),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen(initialTab: 2)),
                    );
                  },
                  child: const Text(
                    'AI 가이드 보기 →',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Ask AI row
          WhiteCard(
            padding: const EdgeInsets.all(16),
            onTap: () => Navigator.pushNamed(context, '/ai-chat'),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/ic_ai_ask.svg',
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn),
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
          const SectionTitle(text: '다음 관리 추천'),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '브라이트닝 부스터 케어',
                  style: TextStyle(
                    color: AppColors.whsBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '울쎄라 시술 후 남을 수 있는 색소침착 예방을 위해 추천드려요',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                OutlineActionButton(
                  text: '추천 상세 보기',
                  leading: SvgPicture.asset('assets/svg/ic_sparkle.svg', width: 18, height: 18),
                  onPressed: () => Navigator.pushNamed(context, '/ai-recommend'),
                ),
              ],
            ),
          ),

          // Voucher status
          const SectionTitle(text: '이용권 현황'),
          WhiteCard(
            child: Column(
              children: [
                _buildVoucherRow('엠레드 울쎄라 3회권', 1, 3, AppColors.amred),
                const SizedBox(height: 18),
                _buildVoucherRow('더나 입술 필러', 1, 3, AppColors.derna),
                const SizedBox(height: 18),
                _buildVoucherRow('윔 지방분해 3회권', 2, 3, AppColors.wim),
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
              '잔여 $remaining회 ﹥',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: used / total,
            backgroundColor: AppColors.todayPillBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
