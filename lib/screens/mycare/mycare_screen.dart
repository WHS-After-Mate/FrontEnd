import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/mycare/mycare_service.dart';
import '../../services/mycare/mycare_models.dart';

class MyCareScreen extends StatefulWidget {
  final int initialTab;
  const MyCareScreen({super.key, this.initialTab = 0});

  @override
  State<MyCareScreen> createState() => _MyCareScreenState();
}

class _MyCareScreenState extends State<MyCareScreen> {
  late int _selectedTab;
  final MyCareService _service = MyCareService();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _loadCalendar();
    _loadDayRecords();
    if (widget.initialTab == 1) {
      _loadHistory();
    } else if (widget.initialTab == 2) {
      _loadMemberships();
    }
  }

  // ─── 캘린더 탭 상태 ───
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  int? _selectedDay = DateTime.now().day;

  Map<int, Set<String>> _calendarMarkers = {}; // day → brand set
  bool _calendarLoading = false;
  String? _calendarError;

  List<CareRecordItem> _dayRecords = [];
  bool _dayRecordsLoading = false;
  String? _dayRecordsError;

  // ─── 이력 탭 상태 ───
  String _historyFilter = '전체';
  final List<String> _filters = ['전체', '엠레드', '더나', '윔'];
  final Map<String, Color> _filterColors = {
    '엠레드': AppColors.amred,
    '더나': AppColors.derna,
    '윔': AppColors.wim,
  };

  List<CareRecordItem> _historyItems = [];
  bool _historyLoading = false;
  String? _historyError;

  // ─── 이용권 탭 상태 ───
  List<MembershipItem> _memberships = [];
  bool _membershipsLoading = false;
  String? _membershipsError;

  // ─── 브랜드 → 색상 매핑 ───
  Color _brandColor(String? brand) {
    if (brand == null) return AppColors.whsBlack;
    final b = brand.toUpperCase();
    if (b.contains('AMRED') || brand.contains('엠레드')) return AppColors.amred;
    if (b.contains('DERNA') || brand.contains('더나')) return AppColors.derna;
    if (b.contains('WIM') || brand.contains('윔')) return AppColors.wim;
    return AppColors.whsBlack;
  }

  String _brandLabel(String? brand) {
    if (brand == null || brand.isEmpty) return '';
    final b = brand.toUpperCase();
    if (b.contains('AMRED')) return '엠레드';
    if (b.contains('DERNA')) return '더나';
    if (b.contains('WIM')) return '윔';
    return brand;
  }

  String? _filterToBrand(String filter) {
    switch (filter) {
      case '엠레드':
        return 'AMRED CLINIC';
      case '더나':
        return 'DERNA CLINIC';
      case '윔':
        return 'WIM CLINIC';
      default:
        return null;
    }
  }

  // ─── API 호출 ───
  String get _monthString =>
      '$_currentYear-${_currentMonth.toString().padLeft(2, '0')}';

  Future<void> _loadCalendar() async {
    setState(() {
      _calendarLoading = true;
      _calendarError = null;
    });
    try {
      // 해당 월의 첫째날~마지막날 관리 기록을 가져와서 브랜드별 마커 구성
      final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
      final dateFrom = '$_monthString-01';
      final dateTo = '$_monthString-${daysInMonth.toString().padLeft(2, '0')}';
      final result = await _service.getCareRecords(
        dateFrom: dateFrom,
        dateTo: dateTo,
        size: 100,
      );
      final markers = <int, Set<String>>{};
      for (final item in result.items) {
        final day = int.tryParse(item.careDate.split('-').last);
        if (day != null) {
          markers.putIfAbsent(day, () => <String>{});
          if (item.brand != null && item.brand!.isNotEmpty) {
            markers[day]!.add(item.brand!);
          } else {
            markers[day]!.add('DEFAULT');
          }
        }
      }
      if (mounted) {
        setState(() {
          _calendarMarkers = markers;
          _calendarLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _calendarError = '캘린더를 불러올 수 없습니다';
          _calendarLoading = false;
        });
      }
    }
  }

  Future<void> _loadDayRecords() async {
    if (_selectedDay == null) {
      setState(() => _dayRecords = []);
      return;
    }
    final dateStr =
        '$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}';
    setState(() {
      _dayRecordsLoading = true;
      _dayRecordsError = null;
    });
    try {
      final result = await _service.getCareRecords(
        dateFrom: dateStr,
        dateTo: dateStr,
      );
      if (mounted) {
        setState(() {
          _dayRecords = result.items;
          _dayRecordsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dayRecordsError = '관리 내역을 불러올 수 없습니다';
          _dayRecordsLoading = false;
        });
      }
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _historyLoading = true;
      _historyError = null;
    });
    try {
      final brand = _historyFilter == '전체' ? null : _filterToBrand(_historyFilter);
      final result = await _service.getCareRecords(brand: brand);
      if (mounted) {
        setState(() {
          _historyItems = result.items;
          _historyLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyError = '이력을 불러올 수 없습니다';
          _historyLoading = false;
        });
      }
    }
  }

  Future<void> _loadMemberships() async {
    setState(() {
      _membershipsLoading = true;
      _membershipsError = null;
    });
    try {
      final items = await _service.getMemberships();
      if (mounted) {
        items.sort((a, b) => (b.lastUsedAt ?? '').compareTo(a.lastUsedAt ?? ''));
        setState(() {
          _memberships = items;
          _membershipsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _membershipsError = '이용권을 불러올 수 없습니다';
          _membershipsLoading = false;
        });
      }
    }
  }

  void _onTabChanged(int tab) {
    setState(() => _selectedTab = tab);
    if (tab == 1 && _historyItems.isEmpty && !_historyLoading) {
      _loadHistory();
    } else if (tab == 2 && _memberships.isEmpty && !_membershipsLoading) {
      _loadMemberships();
    }
  }

  void _onMonthChanged(int delta) {
    setState(() {
      _currentMonth += delta;
      if (_currentMonth < 1) {
        _currentMonth = 12;
        _currentYear--;
      } else if (_currentMonth > 12) {
        _currentMonth = 1;
        _currentYear++;
      }
      _selectedDay = null;
      _dayRecords = [];
    });
    _loadCalendar();
  }

  void _onDaySelected(int day) {
    setState(() => _selectedDay = day);
    _loadDayRecords();
  }

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

        // 스크롤 영역: 탭 내용 (페이드 전환)
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: SingleChildScrollView(
              key: ValueKey(_selectedTab),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / 3;
          return Stack(
            children: [
              // 슬라이드 인디케이터
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: _selectedTab * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // 탭 텍스트
              Row(
                children: List.generate(tabs.length, (i) {
                  final selected = _selectedTab == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onTabChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            tabs[i],
                            style: TextStyle(
                              color: selected
                                  ? AppColors.whsBlack
                                  : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight:
                                  selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── 캘린더 탭 ───
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
                    onTap: () => _onMonthChanged(-1),
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
                    onTap: () => _onMonthChanged(1),
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
              if (_calendarLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (_calendarError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Text(_calendarError!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _loadCalendar,
                          child: const Text('다시 시도',
                              style: TextStyle(
                                  color: AppColors.calendarAccent, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
        _buildDayRecordsSection(),
      ],
    );
  }

  Widget _buildDayRecordsSection() {
    if (_dayRecordsLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_dayRecordsError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: [
              Text(_dayRecordsError!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _loadDayRecords,
                child: const Text('다시 시도',
                    style:
                        TextStyle(color: AppColors.calendarAccent, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }
    if (_selectedDay == null || _dayRecords.isEmpty) {
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
              SvgPicture.asset('assets/svg/ic_calendar_add.svg',
                  width: 15, height: 15),
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
          ..._dayRecords.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildCareHistoryItem(r),
              )),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0=Sun

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
          final hasMarker = _calendarMarkers.containsKey(currentDay);

          cells.add(Expanded(
            child: GestureDetector(
              onTap: () => _onDaySelected(currentDay),
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
                          color:
                              isSelected ? AppColors.white : AppColors.whsBlack,
                          fontSize: 14,
                          fontWeight: isToday || isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasMarker)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _calendarMarkers[currentDay]!
                            .take(3)
                            .map((brand) => Container(
                                  margin: const EdgeInsets.only(top: 2, left: 1, right: 1),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: _brandColor(brand == 'DEFAULT' ? null : brand),
                                    shape: BoxShape.circle,
                                  ),
                                ))
                            .toList(),
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
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildCareHistoryItem(CareRecordItem record) {
    final color = _brandColor(record.brand);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/care-detail',
          arguments: record.careRecordId,
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
                  Text(record.careName,
                      style: const TextStyle(
                          color: AppColors.whsBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(_brandLabel(record.brand),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Text('>',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  // ─── 이력 탭 ───
  Widget _buildHistoryTab() {
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
                  onTap: () {
                    setState(() => _historyFilter = filter);
                    _loadHistory();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.whsBlack : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            selected ? AppColors.whsBlack : AppColors.cardBorder,
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
                            color:
                                selected ? AppColors.white : AppColors.whsBlack,
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
        if (_historyLoading)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_historyError != null)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(
              child: Column(
                children: [
                  Text(_historyError!,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _loadHistory,
                    child: const Text('다시 시도',
                        style: TextStyle(
                            color: AppColors.calendarAccent, fontSize: 13)),
                  ),
                ],
              ),
            ),
          )
        else if (_historyItems.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text('관리한 내역이 없어요',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
          )
        else
          ..._historyItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildHistoryCard(item),
              )),
      ],
    );
  }

  Widget _buildHistoryCard(CareRecordItem item) {
    final color = _brandColor(item.brand);
    // Parse date from careDate (format: "YYYY-MM-DD")
    final dateParts = item.careDate.split('-');
    final month = int.tryParse(dateParts.length > 1 ? dateParts[1] : '0') ?? 0;
    final day = int.tryParse(dateParts.length > 2 ? dateParts[2] : '0') ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/care-detail',
          arguments: item.careRecordId,
        );
      },
      child: WhiteCard(
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
                      ColorDot(color: color, size: 8),
                      const SizedBox(width: 6),
                      Text(
                        _brandLabel(item.brand),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 관리명
                  Text(
                    item.careName,
                    style: const TextStyle(
                        color: AppColors.whsBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  // 날짜
                  Text(
                    '$month월 $day일',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.status == 'completed' || item.status == '완료'
                    ? AppColors.calendarAccent.withValues(alpha: 0.1)
                    : AppColors.derna.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(item.status),
                style: TextStyle(
                  color: item.status == 'completed' || item.status == '완료'
                      ? AppColors.calendarAccent
                      : AppColors.whsBlack,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'scheduled':
        return '예정';
      case 'cancelled':
        return '취소';
      default:
        return status;
    }
  }

  // ─── 이용권 탭 ───
  Widget _buildVoucherTab() {
    if (_membershipsLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_membershipsError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: [
              Text(_membershipsError!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _loadMemberships,
                child: const Text('다시 시도',
                    style: TextStyle(
                        color: AppColors.calendarAccent, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }
    if (_memberships.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: Text('이용권이 없어요',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ),
      );
    }

    return Column(
      children: _memberships.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final color = _brandColor(item.brand);
        final brandLabel = _brandLabel(item.brand);
        // Format expiry date
        final expiry = item.expiresAt != null
            ? item.expiresAt!.substring(0, 10).replaceAll('-', '.')
            : '-';
        // Format usage history dates
        final sessions = item.usageHistory
            .map((u) => _formatUsageDate(u.usedAt))
            .toList();

        return Padding(
          padding: EdgeInsets.only(bottom: index < _memberships.length - 1 ? 12 : 0),
          child: _VoucherExpandCard(
            name: brandLabel.isNotEmpty
                ? '$brandLabel ${item.productName} ${item.totalCount}회권'
                : '${item.productName} ${item.totalCount}회권',
            brand: brandLabel.isNotEmpty ? brandLabel : item.productName,
            remaining: item.remainingCount,
            total: item.totalCount,
            color: color,
            expiry: expiry,
            sessions: sessions,
          ),
        );
      }).toList(),
    );
  }

  String _formatUsageDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      final weekday = weekdays[date.weekday - 1];
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}($weekday)';
    } catch (_) {
      return dateStr;
    }
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
  int _expandCount = 0;

  @override
  Widget build(BuildContext context) {
    final used = widget.total - widget.remaining;
    final percent = widget.total > 0 ? ((used / widget.total) * 100).round() : 0;

    return GestureDetector(
      onTap: () => setState(() {
        _expanded = !_expanded;
        if (_expanded) _expandCount++;
      }),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState:
            _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: _buildCollapsed(used),
        secondChild: KeyedSubtree(
          key: ValueKey(_expandCount),
          child: _buildExpanded(used, percent),
        ),
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
                  style: const TextStyle(
                      color: AppColors.whsBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.remaining}',
                      style: const TextStyle(
                          color: AppColors.whsBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: ' 회 남음',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                  begin: 0.0,
                  end: widget.total > 0 ? used / widget.total : 0.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.todayPillBg,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  minHeight: 6,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('사용기간',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                  Text('~ ${widget.expiry}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Center(
            child: Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecondary, size: 24),
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
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.remaining}',
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                        begin: 0.0,
                        end: widget.total > 0 ? used / widget.total : 0.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        backgroundColor: widget.color.withValues(alpha: 0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(widget.color),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '$value%',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
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
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B3B3C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${i + 1}회차',
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.sessions[i],
                    style:
                        const TextStyle(color: AppColors.white, fontSize: 14),
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
                  const Text('사용기간',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Text('~ ${widget.expiry}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Center(
            child: Icon(Icons.keyboard_arrow_up,
                color: AppColors.white, size: 24),
          ),
        ],
      ),
    );
  }
}
