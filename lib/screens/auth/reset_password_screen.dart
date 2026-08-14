import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _codeSent = false;
  String? _emailError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool get _isEmailValid =>
      _emailController.text.trim().isNotEmpty && validateEmail(_emailController.text) == null;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendCode() {
    setState(() => _codeSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증번호가 발송되었습니다')),
    );
  }

  void _onEmailChanged(String value) {
    setState(() => _emailError = validateEmail(value));
  }

  void _onNewPasswordChanged(String value) {
    setState(() => _newPasswordError = validatePassword(value));
    if (_confirmPasswordController.text.isNotEmpty) {
      _onConfirmPasswordChanged(_confirmPasswordController.text);
    }
  }

  void _onConfirmPasswordChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = null;
      } else if (value != _newPasswordController.text) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.whsBlack),
                ),
              ),

              const Text(
                '비밀번호를 잊으셨나요?',
                style: TextStyle(
                  color: AppColors.whsBlack,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '가입하신 이메일을 입력하시면 재설정 링크를 보내드려요',
                style: TextStyle(
                  color: AppColors.whsBlack.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // 이메일 + 인증번호 발송
              Text(
                '이메일',
                style: TextStyle(
                  color: AppColors.whsBlack.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: _onEmailChanged,
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                          hintStyle: TextStyle(color: Color(0x4D0A0A0B), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        style: const TextStyle(color: AppColors.whsBlack, fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: _isEmailValid ? _sendCode : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isEmailValid ? AppColors.whsBlack : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isEmailValid ? AppColors.whsBlack : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            '인증번호 발송',
                            style: TextStyle(
                              color: _isEmailValid ? AppColors.white : AppColors.whsBlack.withValues(alpha: 0.3),
                              fontSize: 12,
                              fontWeight: _isEmailValid ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
              const SizedBox(height: 20),

              // 인증번호 입력
              Text(
                '인증번호 입력',
                style: TextStyle(
                  color: AppColors.whsBlack.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: _codeSent ? 1.0 : 0.4,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: _codeSent ? AppColors.white : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: _codeSent,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '인증번호 입력',
                            hintStyle: TextStyle(color: Color(0x4D0A0A0B), fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          style: const TextStyle(color: AppColors.whsBlack, fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: _codeSent ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('인증번호가 확인되었습니다')),
                            );
                          } : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _codeSent ? AppColors.whsBlack : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _codeSent ? AppColors.whsBlack : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              '인증번호 확인',
                              style: TextStyle(
                                color: _codeSent ? AppColors.white : AppColors.whsBlack.withValues(alpha: 0.3),
                                fontSize: 12,
                                fontWeight: _codeSent ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 새 비밀번호
              AppTextField(
                label: '새 비밀번호',
                hint: '••••••••',
                obscureText: _obscureNew,
                controller: _newPasswordController,
                onChanged: _onNewPasswordChanged,
                errorText: _newPasswordError,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureNew = !_obscureNew),
                  child: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
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
                onChanged: _onConfirmPasswordChanged,
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

              const Spacer(),

              // 버튼
              BlackButton(
                text: '비밀번호 변경하기',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
