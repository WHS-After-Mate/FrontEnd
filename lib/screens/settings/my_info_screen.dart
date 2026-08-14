import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/validators.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  bool _obscurePrev = true;
  bool _obscureNew = true;

  final _prevPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String? _prevPasswordError;
  String? _newPasswordError;

  final _nameController = TextEditingController(text: '지수');
  final _birthController = TextEditingController(text: '2000-01-04');
  final _emailController = TextEditingController(text: 'abc@gmail.com');
  final _phoneController = TextEditingController(text: '010-1111-2222');

  String? _emailError;
  String? _phoneError;
  String? _birthError;

  final List<String> _interestOptions = [
    '리프팅·탄력', '모공·피지 관리', '보습·장벽 강화',
    '색소침착 개선', '얼굴 윤곽·볼륨', '제모', '두피 관리',
    '바디라인·체형 관리', '붓기 케어', '컨디션·대사 관리',
  ];
  final Set<String> _selectedInterests = {'리프팅·탄력', '모공·피지 관리'};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header (실선 제거)
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
                      children: const [
                        AvatarCircle(initial: '지', size: 56, fontSize: 18),
                        SizedBox(width: 12),
                        Text(
                          '지수님',
                          style: TextStyle(
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
                          _buildEditableRow('이름', _nameController, null, null, null),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildEditableRow(
                            '생년월일',
                            _birthController,
                            TextInputType.number,
                            [BirthDateFormatter()],
                            (v) => setState(() => _birthError = validateBirth(v)),
                          ),
                          if (_birthError != null && _birthError!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(_birthError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                              ),
                            ),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildEditableRow(
                            '이메일',
                            _emailController,
                            TextInputType.emailAddress,
                            null,
                            (v) => setState(() => _emailError = validateEmail(v)),
                          ),
                          if (_emailError != null && _emailError!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(_emailError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                              ),
                            ),
                          const Divider(height: 28, color: AppColors.divider),
                          _buildEditableRow(
                            '휴대폰 번호',
                            _phoneController,
                            TextInputType.phone,
                            [PhoneNumberFormatter()],
                            (v) => setState(() => _phoneError = validatePhone(v)),
                          ),
                          if (_phoneError != null && _phoneError!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(_phoneError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                              ),
                            ),
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
                text: '저장하기',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('저장되었습니다')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(
    String label,
    TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChanged,
  ) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            onChanged: onChanged,
            textAlign: TextAlign.end,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(color: AppColors.whsBlack, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
