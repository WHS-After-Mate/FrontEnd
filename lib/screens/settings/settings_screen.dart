import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth/auth_service.dart';
import '../../services/profile/profile_service.dart';
import '../../services/profile/profile_models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _careNotification = false;
  bool _marketingNotification = false;
  bool _notificationLoaded = false;
  bool _isLoggingOut = false;

  final _authService = AuthService();
  final _profileService = ProfileService();
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _careNotification = prefs.getBool('care_notification') ?? false;
      _marketingNotification = prefs.getBool('marketing_notification') ?? false;
      _notificationLoaded = true;
    });
  }

  Future<void> _setCareNotification(bool value) async {
    setState(() => _careNotification = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('care_notification', value);
  }

  Future<void> _setMarketingNotification(bool value) async {
    setState(() => _marketingNotification = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('marketing_notification', value);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (e) {
      debugPrint('[SettingsScreen] 프로필 로드 실패: $e');
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '설정',
                  style: TextStyle(
                    color: AppColors.whsBlack,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Profile card
                WhiteCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => Navigator.pushNamed(context, '/my-info'),
                  child: Row(
                    children: [
                      AvatarCircle(
                        initial: _profile?.name.isNotEmpty == true
                            ? _profile!.name.substring(0, 1)
                            : '',
                        size: 48,
                        fontSize: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile != null ? '${_profile!.name}님' : '불러오는 중...',
                              style: TextStyle(
                                color: _profile != null ? AppColors.whsBlack : AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _profile?.email ?? '',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Text('>', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                ),

                // Notification settings
                const SectionTitle(text: '알림 설정'),
                WhiteCard(
                  child: Column(
                    children: [
                      // 사후관리 알림
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '사후관리 알림',
                                  style: TextStyle(
                                    color: AppColors.whsBlack,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '경과일에 맞는 케어 안내를 받아요',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _careNotification,
                            onChanged: _notificationLoaded ? (v) => _setCareNotification(v) : null,
                            activeThumbColor: AppColors.white,
                            activeTrackColor: AppColors.whsBlack,
                            inactiveThumbColor: AppColors.white,
                            inactiveTrackColor: AppColors.switchTrackOff,
                            trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: AppColors.divider),
                      // 마케팅 알림
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '마케팅 알림',
                                  style: TextStyle(
                                    color: AppColors.whsBlack,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '혜택 및 이벤트 소식을 받아요',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _marketingNotification,
                            onChanged: _notificationLoaded ? (v) => _setMarketingNotification(v) : null,
                            activeThumbColor: AppColors.white,
                            activeTrackColor: AppColors.whsBlack,
                            inactiveThumbColor: AppColors.white,
                            inactiveTrackColor: AppColors.switchTrackOff,
                            trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Logout button (fixed)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isLoggingOut ? null : _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whsBlack,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                _isLoggingOut ? '로그아웃 중...' : '로그아웃',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
