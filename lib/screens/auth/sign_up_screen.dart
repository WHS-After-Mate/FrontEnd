import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _phoneError;
  String? _birthError;
  String? _passwordError;
  String? _confirmPasswordError;

  final List<String> _interestOptions = [
    '리프팅·탄력', '모공·피지 관리', '보습·장벽 강화',
    '색소침착 개선', '얼굴 윤곽·볼륨', '제모', '두피 관리',
    '바디라인·체형 관리', '붓기 케어', '컨디션·대사 관리',
  ];
  final Set<String> _selectedInterests = {};

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() => _emailError = validateEmail(value));
  }

  void _validatePhone(String value) {
    setState(() => _phoneError = validatePhone(value));
  }

  void _validateBirth(String value) {
    setState(() => _birthError = validateBirth(value));
  }

  void _validatePassword(String value) {
    setState(() => _passwordError = validatePassword(value));
    // 확인 필드도 다시 검사
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = null;
      } else if (value != _passwordController.text) {
        _confirmPasswordError = '비밀번호가 일치하지 않습니다';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 뒤로가기 (고정)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 12, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.whsBlack),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    const Text(
                      '회원가입',
                      style: TextStyle(
                        color: AppColors.whsBlack,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '몇 가지 정보만 알려주시면 시작할 수 있어요',
                      style: TextStyle(
                        color: AppColors.whsBlack.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 이름
                    AppTextField(
                      label: '이름',
                      hint: '이름을 입력해주세요',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),

                    // 생년월일
                    AppTextField(
                      label: '생년월일',
                      hint: 'YYYY-MM-DD',
                      controller: _birthController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [BirthDateFormatter()],
                      onChanged: _validateBirth,
                      errorText: _birthError,
                    ),
                    const SizedBox(height: 20),

                    // 이메일
                    AppTextField(
                      label: '이메일',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _validateEmail,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 20),

                    // 휴대폰 번호
                    AppTextField(
                      label: '휴대폰 번호',
                      hint: '010-0000-0000',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneNumberFormatter()],
                      onChanged: _validatePhone,
                      errorText: _phoneError,
                    ),
                    const SizedBox(height: 20),

                    // 비밀번호
                    AppTextField(
                      label: '비밀번호',
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      onChanged: _validatePassword,
                      errorText: _passwordError,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 비밀번호 재확인
                    AppTextField(
                      label: '비밀번호 재확인',
                      hint: '••••••••',
                      obscureText: _obscureConfirm,
                      controller: _confirmPasswordController,
                      onChanged: _validateConfirmPassword,
                      errorText: _confirmPasswordError,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        child: Icon(
                          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 관심 목표
                    Text(
                      '관심 목표',
                      style: TextStyle(
                        color: AppColors.whsBlack.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _interestOptions.map((option) {
                        final selected = _selectedInterests.contains(option);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedInterests.remove(option);
                              } else {
                                _selectedInterests.add(option);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.whsBlack : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? AppColors.whsBlack : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                color: selected ? AppColors.white : AppColors.whsBlack,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: BlackButton(
                text: '가입하고 시작하기',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
