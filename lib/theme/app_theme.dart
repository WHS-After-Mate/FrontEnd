import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFAFAF8);
  static const Color whsBlack = Color(0xFF0A0A0B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color divider = Color(0xFFECECEC);
  static const Color cardBorder = Color(0xFFEFEFEF);
  static const Color navIconInactive = Color(0xFFADADB2);
  static const Color switchTrackOff = Color(0xFFE4E4E4);
  static const Color hintColor = Color(0xFFBCBCBC);

  // Brand colors
  static const Color amred = Color(0xFFA3A9FF);
  static const Color derna = Color(0xFFFFF84A);
  static const Color wim = Color(0xFF7AD9B5);

  // Calendar
  static const Color calendarAccent = Color(0xFF3B6CF6);
  static const Color todayPillBg = Color(0xFFEDEDED);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.whsBlack,
          onPrimary: AppColors.white,
          surface: AppColors.background,
          onSurface: AppColors.whsBlack,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.whsBlack,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.whsBlack,
          unselectedItemColor: AppColors.navIconInactive,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
      );
}
