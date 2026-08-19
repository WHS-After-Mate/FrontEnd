import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth/auth_service.dart';
import '../../services/fcm/fcm_service.dart';
import '../../services/profile/profile_service.dart';
import '../../services/profile/profile_models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _careNotification = true;
  bool _marketingNotification = true;
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
    try {
      final settings = await _profileService.getNotificationSettings();
      if (!mounted) return;
      setState(() {
        _careNotification = settings.careNotification;
        _marketingNotification = settings.marketingNotification;
        _notificationLoaded = true;
      });
    } catch (e) {
      debugPrint('[SettingsScreen] 알림 설정 로드 실패: $e');
      // 실패 시 기본값(true)으로 표시
      if (!mounted) return;
      setState(() => _notificationLoaded = true);
    }
  }

  Future<void> _setCareNotification(bool value) async {
    setState(() => _careNotification = value);
    try {
      await _profileService.updateNotificationSettings(
        NotificationSettingsUpdate(careNotification: value),
      );
    } catch (e) {
      debugPrint('[SettingsScreen] 사후관리 알림 변경 실패: $e');
      // 실패 시 롤백
      if (!mounted) return;
      setState(() => _careNotification = !value);
    }
  }

  Future<void> _setMarketingNotification(bool value) async {
    setState(() => _marketingNotification = value);
    try {
      await _profileService.updateNotificationSettings(
        NotificationSettingsUpdate(marketingNotification: value),
      );
    } catch (e) {
      debugPrint('[SettingsScreen] 마케팅 알림 변경 실패: $e');
      // 실패 시 롤백
      if (!mounted) return;
      setState(() => _marketingNotification = !value);
    }
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
    await FcmService().unregisterToken();
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
