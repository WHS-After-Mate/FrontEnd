import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../main_screen.dart';
import '../../services/mycare/mycare_service.dart';
import '../../services/mycare/mycare_models.dart';

Color getBrandColor(String? brand) {
  if (brand == null) return AppColors.whsBlack;
  final b = brand.toLowerCase();
  if (b.contains('amred') || b.contains('엠레드')) return AppColors.amred;
  if (b.contains('derna') || b.contains('더나')) return AppColors.derna;
  if (b.contains('wim') || b.contains('윔')) return AppColors.wim;
  return AppColors.whsBlack;
}

String getBrandLabel(String? brand) {
  if (brand == null || brand.isEmpty) return '';
  final b = brand.toUpperCase();
  if (b.contains('AMRED')) return '엠레드 클리닉';
  if (b.contains('DERNA')) return '더나 의원';
  if (b.contains('WIM')) return '윔 센터';
  return brand;
}

String getStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return '관리 완료';
    case 'scheduled':
      return '예약됨';
    case 'cancelled':
      return '취소됨';
    default:
      return status;
  }
}

class CareDetailScreen extends StatefulWidget {
  final String careRecordId;

  const CareDetailScreen({
    super.key,
    required this.careRecordId,
  });

  @override
  State<CareDetailScreen> createState() => _CareDetailScreenState();
}

class _CareDetailScreenState extends State<CareDetailScreen> {
  final _myCareService = MyCareService();

  CareRecordDetail? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await _myCareService.getCareRecordDetail(widget.careRecordId);
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatCareDate(String careDate) {
    try {
      final date = DateTime.parse(careDate);
      return '${date.month}월 ${date.day}일';
    } catch (_) {
      return careDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 콘텐츠
            Positioned.fill(
              bottom: 72,
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
                    child: _buildBody(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.whsBlack),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '데이터를 불러올 수 없습니다.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadDetail,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.whsBlack,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '다시 시도',
                  style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final detail = _detail!;
    final brandColor = getBrandColor(detail.brand);
    final sessionText = detail.session != null
        ? '${detail.session!.number}회차'
        : '-';
    final voucherText = detail.membership != null
        ? (detail.membership!.totalCount != null
            ? '${detail.membership!.totalCount}회권'
            : '-')
        : '-';
    final practitionerText = detail.practitioner != null
        ? '${detail.practitioner!} 원장'
        : '-';

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 관리명
                Text(
                  detail.careName,
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
                    if (detail.brand != null) ...[
                      ColorDot(color: brandColor, size: 10),
                      const SizedBox(width: 8),
                      Text(
                        getBrandLabel(detail.brand),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: detail.status == 'completed' || detail.status == '완료'
                            ? AppColors.calendarAccent.withValues(alpha: 0.1)
                            : AppColors.derna.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getStatusLabel(detail.status),
                        style: TextStyle(
                          color: detail.status == 'completed' || detail.status == '완료'
                              ? AppColors.calendarAccent
                              : AppColors.whsBlack,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                      _buildDetailRow('관리 일시', _formatCareDate(detail.careDate)),
                      const Divider(height: 28, color: AppColors.divider),
                      _buildDetailRow('관리 부위', detail.partOfBody.join(', ')),
                      const Divider(height: 28, color: AppColors.divider),
                      _buildDetailRow('경과일', '관리 후 ${detail.daysElapsed}일차'),
                      const Divider(height: 28, color: AppColors.divider),
                      _buildDetailRow('관리 회차', sessionText),
                      const Divider(height: 28, color: AppColors.divider),
                      _buildDetailRow('이용권', voucherText),
                      const Divider(height: 28, color: AppColors.divider),
                      _buildDetailRow('담당자', practitionerText),
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => MainScreen(
                    initialTab: 2,
                    guideCareRecordId: detail.careRecordId,
                  ),
                ),
                (route) => false,
              );
            },
          ),
        ),
      ],
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
