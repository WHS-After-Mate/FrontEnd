import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/validators.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/auth_models.dart';
import '../../services/api/api_exception.dart';
import '../../utils/toast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _pageController = PageController();
  final _step1ScrollController = ScrollController();
  int _currentPage = 0;
  bool _isLoading = false;

  // 1단계: 환자 확인
  final _patientNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  String? _birthError;
  String? _step1Error; // 매칭 실패 시 표시할 에러

  // 2단계: 계정 생성
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _interestError;

  final _authService = AuthService();

  final List<String> _interestOptions = [
    '리프팅·탄력', '모공·피지 관리', '보습·장벽 강화',
    '색소침착 개선', '얼굴 윤곽·볼륨', '제모', '두피 관리',
    '바디라인·체형 관리', '붓기 케어', '컨디션·대사 관리',
  ];
  final Set<String> _selectedInterests = {};

  @override
  void dispose() {
    _pageController.dispose();
    _step1ScrollController.dispose();
    _patientNoController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateBirth(String value) {
    setState(() => _birthError = validateBirth(value));
  }

  void _validateEmail(String value) {
    setState(() => _emailError = validateEmail(value));
  }

  void _validatePhone(String value) {
    setState(() => _phoneError = validatePhone(value));
  }

  void _validatePassword(String value) {
    setState(() => _passwordError = validatePassword(value));
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

  /// 1단계 → 2단계 이동 (서버 pre-check로 환자번호+이름+생년월일+전화번호 대조)
  void _scrollStep1ToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_step1ScrollController.hasClients) {
        _step1ScrollController.animateTo(
          _step1ScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _goToStep2() async {
    final patientNo = _patientNoController.text.trim();
    final name = _nameController.text.trim();
    final birth = _birthController.text.trim();
    final phone = _phoneController.text.trim();

    if (patientNo.isEmpty || name.isEmpty || birth.isEmpty || phone.isEmpty) {
      setState(() => _step1Error = '모든 항목을 입력해주세요');
      _scrollStep1ToBottom();
      return;
    }

    final birthErr = validateBirth(birth);
    final phoneErr = validatePhone(phone);
    if (birthErr != null || phoneErr != null) {
      setState(() {
        _birthError = birthErr;
        _phoneError = phoneErr;
      });
      return;
    }

    // 서버에 본인확인 대조 요청
    setState(() {
      _step1Error = null;
      _isLoading = true;
    });

    try {
      await _authService.signupPreCheck(
        patientNo: patientNo,
        name: name,
        birthDate: birth,
        phone: phone.replaceAll('-', ''),
      );

      if (!mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'PATIENT_NOT_FOUND':
          message = '해당 환자번호를 찾을 수 없습니다. 병원에 문의해주세요.';
          break;
        case 'PATIENT_ALREADY_CLAIMED':
          message = '이미 가입된 환자번호입니다.';
          break;
        case 'PATIENT_IDENTITY_MISMATCH':
          message = '입력한 정보가 등록된 환자 정보와 일치하지 않습니다.';
          break;
        default:
          message = e.message;
      }
      setState(() => _step1Error = message);
      _scrollStep1ToBottom();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 2단계 → 1단계로 돌아가기
  void _goToStep1() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 최종 가입 요청
  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 모든 필수 항목 유효성 검사
    bool hasError = false;

    // 이메일 필수 + 형식
    String? emailErr;
    if (email.isEmpty) {
      emailErr = '이메일을 입력해주세요';
      hasError = true;
    } else {
      emailErr = validateEmail(email);
      if (emailErr != null) hasError = true;
    }

    // 비밀번호 필수 + 형식
    String? passwordErr;
    if (password.isEmpty) {
      passwordErr = '비밀번호를 입력해주세요';
      hasError = true;
    } else {
      passwordErr = validatePassword(password);
      if (passwordErr != null) hasError = true;
    }

    // 비밀번호 재확인 필수 + 일치
    String? confirmErr;
    if (confirmPassword.isEmpty) {
      confirmErr = '비밀번호를 다시 입력해주세요';
      hasError = true;
    } else if (password != confirmPassword) {
      confirmErr = '비밀번호가 일치하지 않습니다';
      hasError = true;
    }

    // 관심 목표 필수
    String? interestErr;
    if (_selectedInterests.isEmpty) {
      interestErr = '관심 목표를 최소 1개 선택해주세요';
      hasError = true;
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmErr;
      _interestError = interestErr;
    });

    if (hasError) return;

    setState(() => _isLoading = true);
    try {
      await _authService.signup(SignupRequest(
        patientNo: _patientNoController.text.trim(),
        name: _nameController.text.trim(),
        birthDate: _birthController.text.trim(),
        phone: _phoneController.text.trim().replaceAll('-', ''),
        email: email,
        password: password,
        interestGoals: _selectedInterests.toList(),
      ));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      String message;
      bool goBackToStep1 = false;
      switch (e.code) {
        case 'PATIENT_NOT_FOUND':
          message = '해당 환자번호를 찾을 수 없습니다. 병원에 문의해주세요.';
          goBackToStep1 = true;
          break;
        case 'PATIENT_ALREADY_CLAIMED':
          message = '이미 가입된 환자번호입니다';
          goBackToStep1 = true;
          break;
        case 'PATIENT_IDENTITY_MISMATCH':
          message = '이름 또는 생년월일이 등록 정보와 일치하지 않습니다';
          goBackToStep1 = true;
          break;
        case 'EMAIL_ALREADY_EXISTS':
          message = '이미 사용 중인 이메일입니다';
          setState(() => _emailError = message);
          break;
        default:
          message = e.message;
          showToast(message);
      }

      if (goBackToStep1) {
        setState(() => _step1Error = message);
        _goToStep1();
        _scrollStep1ToBottom();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바: 뒤로가기 + 단계 표시
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == 0) {
                        Navigator.pop(context);
                      } else {
                        _goToStep1();
                      }
                    },
                    child: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.whsBlack),
                  ),
                  const Spacer(),
                  // 단계 인디케이터
                  Row(
                    children: [
                      _buildStepDot(0),
                      const SizedBox(width: 8),
                      _buildStepDot(1),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 22), // 균형 맞추기
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDot(int index) {
    final isActive = _currentPage == index;
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.whsBlack : AppColors.cardBorder,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// 1단계: 환자 확인
  Widget _buildStep1() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _step1ScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '본인 확인',
                  style: TextStyle(
                    color: AppColors.whsBlack,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '병원에서 받은 환자번호와 이름, 생년월일을\n입력해주세요',
                  style: TextStyle(
                    color: AppColors.whsBlack.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // 환자번호
                AppTextField(
                  label: '환자번호',
                  hint: 'EMR-P-XXXXXX',
                  controller: _patientNoController,
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

                // 에러 메시지
                if (_step1Error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _step1Error!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // 다음 버튼
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: BlackButton(
            text: _isLoading ? '확인 중...' : '다음',
            onPressed: _isLoading ? null : _goToStep2,
          ),
        ),
      ],
    );
  }

  /// 2단계: 계정 생성
  Widget _buildStep2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '계정 만들기',
                  style: TextStyle(
                    color: AppColors.whsBlack,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '로그인에 사용할 이메일과 비밀번호를 설정해주세요',
                  style: TextStyle(
                    color: AppColors.whsBlack.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

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

                // 비밀번호
                AppTextField(
                  label: '비밀번호',
                  hint: '8자 이상 입력해주세요',
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
                  '관심 목표 (중복선택 가능)',
                  style: TextStyle(
                    color: AppColors.whsBlack.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_interestError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _interestError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
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
                          if (_selectedInterests.isNotEmpty) {
                            _interestError = null;
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

        // 가입 버튼
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: BlackButton(
            text: _isLoading ? '가입 중...' : '가입하고 시작하기',
            onPressed: _isLoading ? null : _handleSignUp,
          ),
        ),
      ],
    );
  }
}
