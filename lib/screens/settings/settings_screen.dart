import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _careNotification = true;
  bool _marketingNotification = true;

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
                      const AvatarCircle(initial: '지', size: 48, fontSize: 16),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '지수님',
                              style: TextStyle(
                                color: AppColors.whsBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'jisoo@example.com',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                            onChanged: (v) => setState(() => _careNotification = v),
                            activeThumbColor: AppColors.white,
                            activeTrackColor: AppColors.whsBlack,
                            inactiveThumbColor: AppColors.white,
                            inactiveTrackColor: AppColors.switchTrackOff,
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
                            onChanged: (v) => setState(() => _marketingNotification = v),
                            activeThumbColor: AppColors.white,
                            activeTrackColor: AppColors.whsBlack,
                            inactiveThumbColor: AppColors.white,
                            inactiveTrackColor: AppColors.switchTrackOff,
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
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whsBlack,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
