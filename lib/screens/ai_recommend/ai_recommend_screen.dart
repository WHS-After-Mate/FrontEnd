import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AiRecommendScreen extends StatelessWidget {
  const AiRecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    const Text(
                      '지수님을 위한\n관리 추천',
                      style: TextStyle(
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

                    // Concern chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['색소침착', '리프팅 후 관리', '탄력'].map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.whsBlack,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(tag, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Best recommendation (dark card)
                    DarkCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '가장 추천하는 관리',
                            style: TextStyle(color: Color(0xFFB8B8BC), fontSize: 13),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '브라이트닝 부스터 케어',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '더나 클리닉 · 권장 시점 2~3주 후',
                            style: TextStyle(color: Color(0xFFB8B8BC), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '최근 관리: 울쎄라 · 21일 전',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),

                    // Reasons
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 10),
                      child: Text(
                        '이 관리를 추천한 이유',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildReasonItem('울쎄라 시술 후 색소침착 예방에 효과적이에요'),
                    const SizedBox(height: 8),
                    _buildReasonItem('시술 3주 경과로 피부 재생 시점에 적합해요'),
                    const SizedBox(height: 8),
                    _buildReasonItem('선택하신 고민 \'색소침착\'에 직접 도움을 줘요'),

                    // Recent care
                    const SectionTitle(text: '최근 관리와 함께 확인했어요'),
                    WhiteCard(
                      child: Column(
                        children: [
                          _buildRecentCareRow('울쎄라 리프팅', '엠레드', 21, AppColors.amred),
                          const Divider(height: 20, color: AppColors.divider),
                          _buildRecentCareRow('수분 광채 관리', '더나', 35, AppColors.derna),
                        ],
                      ),
                    ),

                    // Fit concerns
                    const SectionTitle(text: '이런 고민에 적합해요'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['색소침착', '칙칙한 피부톤', '시술 후 회복'].map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.whsBlack,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(tag, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                    ),

                    // Consult
                    const SectionTitle(text: '상담하기'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildConsultButton(
                            '더나 카톡',
                            'assets/svg/ic_kakao.svg',
                            () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('카카오톡 상담 연결 준비 중이에요')),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildConsultButton(
                            '더나 전화',
                            'assets/svg/ic_call.svg',
                            () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('전화 연결 준비 중이에요')),
                            ),
                          ),
                        ),
                      ],
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

  static Widget _buildReasonItem(String text) {
    return WhiteCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SvgPicture.asset('assets/svg/ic_check.svg', width: 16, height: 16),
          const SizedBox(width: 10),
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

  static Widget _buildRecentCareRow(String name, String brand, int daysAgo, Color color) {
    return Row(
      children: [
        ColorDot(color: color, size: 10),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: name,
                  style: const TextStyle(color: AppColors.whsBlack, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: '  · $brand',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
        Text('$daysAgo일 경과', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  static Widget _buildConsultButton(String text, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: AppColors.whsBlack, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
