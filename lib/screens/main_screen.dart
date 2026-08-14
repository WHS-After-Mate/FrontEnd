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
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          _buildNavItem('assets/svg/ic_home_outline.svg', 'assets/svg/ic_home_fill.svg', '홈'),
          _buildNavItem('assets/svg/ic_care_outline.svg', 'assets/svg/ic_care_fill.svg', 'My Care'),
          _buildNavItem('assets/svg/ic_ai_guide_outline.svg', 'assets/svg/ic_ai_guide_fill.svg', 'AI 가이드'),
          _buildNavItem('assets/svg/ic_settings_outline.svg', 'assets/svg/ic_settings_fill.svg', '설정'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String activeIconPath, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn),
      ),
      activeIcon: SvgPicture.asset(
        activeIconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn),
      ),
      label: label,
    );
  }
}
