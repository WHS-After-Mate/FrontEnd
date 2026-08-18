import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/main_screen.dart';
import 'screens/ai_recommend/ai_recommend_screen.dart';
import 'screens/settings/my_info_screen.dart';
import 'screens/chat/ai_chat_screen.dart';
import 'screens/mycare/care_detail_screen.dart';

/// 앱 전역 Navigator 키 — 인터셉터 등에서 로그인 화면 이동에 사용
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const WhsAfterMateApp());
}

class WhsAfterMateApp extends StatelessWidget {
  const WhsAfterMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'WHS After Mate',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/care-detail') {
          final careRecordId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => CareDetailScreen(careRecordId: careRecordId),
          );
        }
        return null;
      },
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/sign-up': (_) => const SignUpScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/main': (_) => const MainScreen(),
        '/ai-recommend': (_) => const AiRecommendScreen(),
        '/my-info': (_) => const MyInfoScreen(),
        '/ai-chat': (_) => const AiChatScreen(),
      },
    );
  }
}
