import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'care_detail_screen.dart';

class MyCareScreen extends StatefulWidget {
  final int initialTab;
  const MyCareScreen({super.key, this.initialTab = 0});

  @override
  State<MyCareScreen> createState() => _MyCareScreenState();
}

class _MyCareScreenState extends State<MyCareScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  int? _selectedDay = DateTime.now().day;

  // 이력 탭 필터
  String _historyFilter = '전체';
  final List<String> _filters = ['전체', '엠레드', '더나', '윔'];
  final Map<String, Color> _filterColors = {
    '엠레드': AppColors.amred,
    '더나': AppColors.derna,
    '윔': AppColors.wim,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 고정 영역: 타이틀 + 세그먼트 탭
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Care',
                style: TextStyle(
                  color: AppColors.whsBlack,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSegmentTabs(),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // 스크롤 영역: 탭 내용
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedTab == 0) _buildCalendarTab(),
                if (_selectedTab == 1) _buildHistoryTab(),
                if (_selectedTab == 2) _buildVoucherTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentTabs() {
    final tabs = ['캘린더', '이력', '이용권'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.todayPillBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      color: selected ? AppColors.whsBlack : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        // 캘린더 카드
        WhiteCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 월 이동 헤더
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentMonth--;
                        if (_currentMonth < 1) {
                          _currentMonth = 12;
                          _currentYear--;
                        }
                      });
                    },
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.chevron_left, color: AppColors.whsBlack),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_currentYear년 $_currentMonth월',
                        style: const TextStyle(
                          color: AppColors.whsBlack,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentMonth++;
                        if (_currentMonth > 12) {
                          _currentMonth = 1;
                          _currentYear++;
                        }
                      });
                    },
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.chevron_right, color: AppColors.whsBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 요일 헤더
              Row(
                children: ['일', '월', '화', '수', '목', '금', '토']
                    .map((d) => Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                d,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              // 날짜 그리드
              _buildCalendarGrid(),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(AppColors.amred, '엠레드'),
            const SizedBox(width: 16),
            _buildLegend(AppColors.derna, '더나'),
            const SizedBox(width: 16),
            _buildLegend(AppColors.wim, '윔'),
          ],
        ),
        const SizedBox(height: 20),

        // 관리 내역
        Builder(
          builder: (context) {
            final records = _getCareRecords(_selectedDay);
            if (records.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    '관리한 내역이 없어요',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
              );
            }
            return WhiteCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/svg/ic_calendar_add.svg', width: 15, height: 15),
                      const SizedBox(width: 8),
                      Text(
                        '$_currentMonth월 ${_selectedDay ?? '--'}일 관리 내역',
                        style: const TextStyle(
                          color: AppColors.whsBlack,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...records.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildCareHistoryItem(r.name, r.brand, r.session, r.color),
                      )),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0=Sun

    // 관리 있는 날 (더미 데이터) - 복수 사업장 지원
    final careOnDays = <int, List<Color>>{
      5: [AppColors.amred],
      12: [AppColors.derna, AppColors.amred],
      19: [AppColors.wim],
      26: [AppColors.amred, AppColors.derna],
    };

    List<Widget> rows = [];
    int day = 1;

    for (int week = 0; week < 6; week++) {
      if (day > daysInMonth) break;
      List<Widget> cells = [];
      for (int weekday = 0; weekday < 7; weekday++) {
        if (week == 0 && weekday < startWeekday || day > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 44)));
        } else {
          final currentDay = day;
          final isSelected = _selectedDay == currentDay;
          final isToday = currentDay == DateTime.now().day &&
              _currentMonth == DateTime.now().month &&
              _currentYear == DateTime.now().year;
          final careColors = careOnDays[currentDay];

          cells.add(Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = currentDay),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.calendarAccent
                            : isToday
                                ? AppColors.todayPillBg
                                : null,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$currentDay',
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.whsBlack,
                          fontSize: 14,
                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (careColors != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: careColors.map((c) => Container(
                              margin: const EdgeInsets.only(top: 2, left: 1, right: 1),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                            )).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ));
          day++;
        }
      }
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: cells),
      ));
    }

    return Column(children: rows);
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        ColorDot(color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildCareHistoryItem(String name, String brand, String session, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CareDetailScreen(
              name: name,
              brand: brand,
              color: color,
              session: session,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ColorDot(color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: AppColors.whsBlack, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(brand, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Text('>', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  // 더미 데이터: 날짜별 관리 기록
  List<_CareRecord> _getCareRecords(int? day) {
    if (day == null) return [];
    // 더미: 특정 날짜에만 기록 있음
    final records = <int, List<_CareRecord>>{
      5: [_CareRecord('울쎄라 리프팅', '엠레드', '1회차', AppColors.amred)],
      12: [
        _CareRecord('브라이트닝 부스터', '더나', '2회차', AppColors.derna),
        _CareRecord('울쎄라 리프팅', '엠레드', '2회차', AppColors.amred),
      ],
      19: [_CareRecord('두피 스케일링', '윔', '1회차', AppColors.wim)],
      26: [
        _CareRecord('울쎄라 리프팅', '엠레드', '3회차', AppColors.amred),
        _CareRecord('브라이트닝 부스터', '더나', '1회차', AppColors.derna),
      ],
    };
    return records[day] ?? [];
  }

  // 더미 이력 데이터 (최신순)
  final List<_HistoryItem> _historyItems = [
    _HistoryItem('울쎄라 리프팅', '엠레드', 8, 12, 3, '완료', AppColors.amred),
    _HistoryItem('두피 스케일링', '윔', 8, 5, 2, '예정', AppColors.wim),
    _HistoryItem('울쎄라 리프팅', '엠레드', 7, 26, 1, '완료', AppColors.amred),
    _HistoryItem('브라이트닝 부스터', '더나', 7, 20, 1, '완료', AppColors.derna),
    _HistoryItem('수분 광채 관리', '더나', 7, 10, 2, '완료', AppColors.derna),
    _HistoryItem('두피 스케일링', '윔', 6, 28, 1, '완료', AppColors.wim),
  ];

  Widget _buildHistoryTab() {
    var filtered = _historyFilter == '전체'
        ? _historyItems
        : _historyItems.where((item) => item.brand == _historyFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 사업장 필터 칩
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((filter) {
              final selected = _historyFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _historyFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.whsBlack : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.whsBlack : AppColors.cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_filterColors.containsKey(filter)) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _filterColors[filter],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          filter,
                          style: TextStyle(
                            color: selected ? AppColors.white : AppColors.whsBlack,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // 이력 카드들
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text('관리한 내역이 없어요', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
          )
        else
          ...filtered.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildHistoryCard(item),
              )),
      ],
    );
  }

  Widget _buildHistoryCard(_HistoryItem item) {
    return WhiteCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사업장 표시
                Row(
                  children: [
                    ColorDot(color: item.color, size: 8),
                    const SizedBox(width: 6),
                    Text(
                      item.brand,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 관리명
                Text(
                  item.name,
                  style: const TextStyle(color: AppColors.whsBlack, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                // 날짜 · 회차
                Text(
                  '${item.month}월 ${item.day}일 · ${item.session}회차',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.status == '완료'
                  ? AppColors.calendarAccent.withValues(alpha: 0.1)
                  : AppColors.derna.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                color: item.status == '완료' ? AppColors.calendarAccent : AppColors.whsBlack,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherTab() {
    return Column(
      children: [
        _VoucherExpandCard(
          name: '엠레드 울쎄라 3회권',
          brand: '엠레드',
          remaining: 1,
          total: 3,
          color: AppColors.amred,
          expiry: '2026.12.24',
          sessions: ['2026.01.01(월)', '2026.03.01(월)'],
        ),
        const SizedBox(height: 12),
        _VoucherExpandCard(
          name: '더나 브라이트닝 5회권',
          brand: '더나',
          remaining: 2,
          total: 5,
          color: AppColors.derna,
          expiry: '2026.12.24',
          sessions: ['2026.02.10(월)', '2026.04.15(화)', '2026.06.20(금)'],
        ),
        const SizedBox(height: 12),
        _VoucherExpandCard(
          name: '윔 두피 스케일링 4회권',
          brand: '윔',
          remaining: 2,
          total: 4,
          color: AppColors.wim,
          expiry: '2026.12.24',
          sessions: ['2026.01.15(수)', '2026.05.10(토)'],
        ),
      ],
    );
  }
}

class _VoucherExpandCard extends StatefulWidget {
  final String name;
  final String brand;
  final int remaining;
  final int total;
  final Color color;
  final String expiry;
  final List<String> sessions;

  const _VoucherExpandCard({
    required this.name,
    required this.brand,
    required this.remaining,
    required this.total,
    required this.color,
    required this.expiry,
    required this.sessions,
  });

  @override
  State<_VoucherExpandCard> createState() => _VoucherExpandCardState();
}

class _VoucherExpandCardState extends State<_VoucherExpandCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final used = widget.total - widget.remaining;
    final percent = ((used / widget.total) * 100).round();

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: _buildCollapsed(used),
        secondChild: _buildExpanded(used, percent),
      ),
    );
  }

  Widget _buildCollapsed(int used) {
    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ColorDot(color: widget.color, size: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.name,
                  style: const TextStyle(color: AppColors.whsBlack, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.remaining}',
                      style: const TextStyle(color: AppColors.whsBlack, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: ' 회 남음',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: used / widget.total,
              backgroundColor: AppColors.todayPillBg,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('사용기간', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  Text('~ ${widget.expiry}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Center(
            child: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded(int used, int percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whsBlack,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 상단 정보
          Row(
            children: [
              ColorDot(color: widget.color, size: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.name,
                  style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.remaining}',
                      style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: ' 회 남음',
                      style: TextStyle(color: AppColors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 원형 그래프
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: used / widget.total,
                    strokeWidth: 12,
                    backgroundColor: widget.color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 회차별 날짜
          ...List.generate(widget.sessions.length, (i) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B3B3C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${i + 1}회차',
                    style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.sessions[i],
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),

          // 사용기간 + 접기
          Row(
            children: [
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('사용기간', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('~ ${widget.expiry}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Center(
            child: const Icon(Icons.keyboard_arrow_up, color: AppColors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _CareRecord {
  final String name;
  final String brand;
  final String session;
  final Color color;

  const _CareRecord(this.name, this.brand, this.session, this.color);
}

class _HistoryItem {
  final String name;
  final String brand;
  final int month;
  final int day;
  final int session;
  final String status;
  final Color color;

  const _HistoryItem(this.name, this.brand, this.month, this.day, this.session, this.status, this.color);
}
