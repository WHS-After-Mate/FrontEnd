import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() => _emailError = validateEmail(value));
  }

  void _validatePassword(String value) {
    setState(() => _passwordError = validatePassword(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 로고
              const SizedBox(height: 24),
              const Text(
                'WHS',
                style: TextStyle(
                  color: AppColors.whsBlack,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'After Mate',
                style: TextStyle(
                  color: AppColors.whsBlack,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 32),

              // 타이틀
              const Text(
                '관리 이후도, 함께할게요',
                style: TextStyle(
                  color: AppColors.whsBlack,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '최근 관리 이력과 오늘의 사후관리 안내를 확인해보세요',
                style: TextStyle(
                  color: Color(0xFF8E8E8E),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 22),

              // 이메일
              const Text(
                '이메일',
                style: TextStyle(
                  color: Color(0xFF8E8E8E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_emailError != null && _emailError!.isNotEmpty)
                        ? Colors.red
                        : AppColors.cardBorder,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _validateEmail,
                    decoration: const InputDecoration(
                      hintText: 'you@example.com',
                      hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    style: const TextStyle(color: AppColors.whsBlack, fontSize: 16),
                  ),
                ),
              ),
              if (_emailError != null && _emailError!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _emailError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // 비밀번호
              const Text(
                '비밀번호',
                style: TextStyle(
                  color: Color(0xFF8E8E8E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_passwordError != null && _passwordError!.isNotEmpty)
                        ? Colors.red
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: _validatePassword,
                        decoration: const InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 16),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        style: const TextStyle(color: AppColors.whsBlack, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_passwordError != null && _passwordError!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 8),

              // 비밀번호 찾기
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/reset-password'),
                  child: const Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(
                      color: Color(0xFF8E8E8E),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 로그인 버튼
              BlackButton(
                text: '로그인',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
              ),

              const Spacer(),

              // 회원가입 안내
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/sign-up'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 14),
                      children: [
                        TextSpan(text: '계정이 없으신가요? '),
                        TextSpan(
                          text: '회원가입',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.whsBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
