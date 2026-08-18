import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/validators.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/auth_models.dart';
import '../../services/profile/profile_service.dart';
import '../../services/profile/profile_models.dart';
import '../../services/api/api_exception.dart';
import '../../utils/toast.dart';
import '../main_screen.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  bool _obscurePrev = true;
  bool _obscureNew = true;

  final _prevPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String? _prevPasswordError;
  String? _newPasswordError;

  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> _interestOptions = [
    '리프팅·탄력', '모공·피지 관리', '보습·장벽 강화',
    '색소침착 개선', '얼굴 윤곽·볼륨', '제모', '두피 관리',
    '바디라인·체형 관리', '붓기 케어', '컨디션·대사 관리',
  ];
  final Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _prevPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;
      setState(() {
        _nameController.text = profile.name;
        _birthController.text = profile.birthDate ?? '';
        _emailController.text = profile.email;
        _phoneController.text = _formatPhone(profile.phone ?? '');
        _selectedInterests.clear();
        _selectedInterests.addAll(profile.interestGoals);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '프로필을 불러올 수 없습니다';
        _isLoading = false;
      });
    }
  }

  String _formatPhone(String phone) {
    // 01011112222 → 010-1111-2222
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return phone;
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      // 관심 목표 수정
      await _profileService.updateInterests(
        InterestsUpdateRequest(goals: _selectedInterests.toList()),
      );

      // 비밀번호 변경 (입력된 경우만)
      final prevPw = _prevPasswordController.text;
      final newPw = _newPasswordController.text;

      if (prevPw.isNotEmpty || newPw.isNotEmpty) {
        // 이전 비밀번호 유효성 검사
        final prevPwErr = validatePassword(prevPw);
        if (prevPwErr != null) {
          setState(() {
            _prevPasswordError = prevPwErr;
            _isSaving = false;
          });
          return;
        }

        // 새 비밀번호 유효성 검사
        final newPwErr = validatePassword(newPw);
        if (newPwErr != null) {
          setState(() {
            _newPasswordError = newPwErr;
            _isSaving = false;
          });
          return;
        }

        // 이전과 새 비밀번호가 같으면 안 됨
        if (prevPw == newPw) {
          setState(() {
            _newPasswordError = '이전 비밀번호와 다른 비밀번호를 입력해주세요';
            _isSaving = false;
          });
          return;
        }

        try {
          await _profileService.changePassword(PasswordChangeRequest(
            currentPassword: prevPw,
            newPassword: newPw,
          ));
          // 비밀번호 변경 시 Supabase가 기존 세션을 무효화하므로
          // 새 비밀번호로 재로그인하여 토큰을 갱신한다
          await _authService.login(LoginRequest(
            email: _emailController.text,
            password: newPw,
          ));
          _prevPasswordController.clear();
          _newPasswordController.clear();
          setState(() {
            _prevPasswordError = null;
            _newPasswordError = null;
          });
        } on ApiException catch (e) {
          if (e.code == 'INVALID_CURRENT_PASSWORD') {
            setState(() => _prevPasswordError = '현재 비밀번호가 올바르지 않습니다');
            setState(() => _isSaving = false);
            return;
          }
          rethrow;
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      showToast('저장되었습니다');
    } on ApiException catch (e) {
      if (!mounted) return;
      showToast(e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.whsBlack)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _loadProfile,
                child: const Text('다시 시도', style: TextStyle(color: AppColors.whsBlack, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 72,
              child: Column(
                children: [
                  // Header
                  Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.whsBlack),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '내 정보',
                          style: TextStyle(
                            color: AppColors.whsBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + name
                    Row(
                      children: [
                        AvatarCircle(
                          initial: _nameController.text.isNotEmpty ? _nameController.text[0] : '',
                          size: 56,
                          fontSize: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_nameController.text}님',
                          style: const TextStyle(
                            color: AppColors.whsBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // 회원 정보
                    const SectionTitle(text: '회원 정보'),
                    WhiteCard(
                      child: Column(
                        children: [
                          _buildReadOnlyRow('이름', _nameController.text),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildReadOnlyRow('생년월일', _birthController.text),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildReadOnlyRow('이메일', _emailController.text),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildReadOnlyRow('휴대폰 번호', _phoneController.text),
                        ],
                      ),
                    ),

                    // 관심 목표
                    const SectionTitle(text: '관심 목표'),
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

                    // 비밀번호 변경
                    const SectionTitle(text: '비밀번호 변경'),
                    WhiteCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('이전 비밀번호',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              Expanded(
                                child: TextField(
                                  controller: _prevPasswordController,
                                  obscureText: _obscurePrev,
                                  textAlign: TextAlign.end,
                                  onChanged: (v) => setState(() => _prevPasswordError = validatePassword(v)),
                                  decoration: const InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(color: AppColors.textSecondary),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(color: AppColors.whsBlack, fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => setState(() => _obscurePrev = !_obscurePrev),
                                child: Icon(
                                  _obscurePrev ? Icons.visibility_off : Icons.visibility,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (_prevPasswordError != null && _prevPasswordError!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(_prevPasswordError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                              ),
                            ),
                          const Divider(height: 28, color: AppColors.divider),
                          Row(
                            children: [
                              const Text('변경할 비밀번호',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              Expanded(
                                child: TextField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNew,
                                  textAlign: TextAlign.end,
                                  onChanged: (v) => setState(() => _newPasswordError = validatePassword(v)),
                                  decoration: const InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(color: AppColors.textSecondary),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(color: AppColors.whsBlack, fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => setState(() => _obscureNew = !_obscureNew),
                                child: Icon(
                                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (_newPasswordError != null && _newPasswordError!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(_newPasswordError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Save button (fixed)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: BlackButton(
                text: _isSaving ? '저장 중...' : '저장하기',
                onPressed: _isSaving ? null : _handleSave,
              ),
            ),
          ],
        ),
      ),

            // 플로팅 네비게이션 바
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavBar(
                currentIndex: 3,
                onTap: (i) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen(initialTab: i)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }
}
