import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'mycare/mycare_screen.dart';
import 'aiguide/aiguide_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;
  final int myCareTab;
  const MainScreen({super.key, this.initialTab = 0, this.myCareTab = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  late final List<Widget> _screens;

  final List<_NavItem> _navItems = const [
    _NavItem('assets/svg/ic_home_outline.svg', 'assets/svg/ic_home_fill.svg', '홈'),
    _NavItem('assets/svg/ic_care_outline.svg', 'assets/svg/ic_care_fill.svg', 'My Care'),
    _NavItem('assets/svg/ic_ai_guide_outline.svg', 'assets/svg/ic_ai_guide_fill.svg', 'AI 가이드'),
    _NavItem('assets/svg/ic_settings_outline.svg', 'assets/svg/ic_settings_fill.svg', '설정'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _screens = [
      const HomeScreen(),
      MyCareScreen(initialTab: widget.myCareTab),
      const AiGuideScreen(),
      const SettingsScreen(),
    ];
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
              bottom: 60,
              child: _screens[_currentIndex],
            ),

            // 플로팅 네비게이션 바
            Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8E6), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_navItems.length, (i) {
                    final item = _navItems[i];
                    final selected = _currentIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _currentIndex = i),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 64,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              selected ? item.activeIcon : item.icon,
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                selected ? AppColors.whsBlack : AppColors.navIconInactive,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: selected ? AppColors.whsBlack : AppColors.navIconInactive,
                                fontSize: 11,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
