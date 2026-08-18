import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/aftercare/aftercare_service.dart';
import '../../services/aftercare/aftercare_models.dart';
import '../../services/mycare/mycare_service.dart';
import '../../services/mycare/mycare_models.dart';
import '../../services/profile/profile_service.dart';
import '../main_screen.dart';

// ─── 메시지 타입 ───

enum MessageType { text, suggestions, careSelection }

/// 추천 질문 — 짧은 라벨(UI 표시)과 전체 질문(API 전송)을 분리
class SuggestedQuestion {
  final String label;
  final String question;
  const SuggestedQuestion({required this.label, required this.question});
}

class ChatMessage {
  final MessageType type;
  final String? text;
  final bool isUser;
  final List<SuggestedQuestion>? suggestions;
  final List<CareRecordItem>? cares;
  final String? consultationLevel; // NONE | RECOMMENDED | URGENT

  const ChatMessage({
    required this.type,
    this.text,
    required this.isUser,
    this.suggestions,
    this.cares,
    this.consultationLevel,
  });
}

// ─── 챗봇 화면 ───

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _aftercareService = AftercareService();
  final _myCareService = MyCareService();
  final _profileService = ProfileService();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoading = true;

  String _userName = '';
  List<CareRecordItem> _recentCares = [];
  CareRecordItem? _selectedCare;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 프로필과 관리 이력을 각각 로드 (하나 실패해도 다른 것은 계속)
      String userName = '';
      List<CareRecordItem> cares = [];

      try {
        final profile = await _profileService.getProfile();
        userName = profile.name;
      } catch (_) {}

      try {
        final result = await _myCareService.getCareRecords(size: 4);
        cares = result.items;
      } catch (_) {}

      if (!mounted) return;

      _userName = userName;
      _recentCares = cares;

      if (_recentCares.isNotEmpty) {
        _selectedCare = _recentCares.first;
        final care = _recentCares.first;
        final daysElapsed = DateTime.now().difference(DateTime.parse(care.careDate)).inDays;

        _messages.add(ChatMessage(
          type: MessageType.text,
          text: '안녕하세요${_userName.isNotEmpty ? ', $_userName님' : ''}.\n최근에 받은 ${care.careName}은 현재 관리 후 $daysElapsed일차예요.\n사후관리와 관련해 어떤 점이 궁금하신가요?',
          isUser: false,
        ));

        _messages.add(ChatMessage(
          type: MessageType.suggestions,
          isUser: false,
          suggestions: _getSuggestedQuestions(daysElapsed),
        ));
      } else {
        _messages.add(const ChatMessage(
          type: MessageType.text,
          text: '안녕하세요! 최근 관리 이력이 없습니다.\n관리를 받으신 후 다시 방문해주세요.',
          isUser: false,
        ));
      }

      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add(const ChatMessage(
          type: MessageType.text,
          text: '데이터를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
          isUser: false,
        ));
      });
    }
  }

  List<SuggestedQuestion> _getSuggestedQuestions(int daysElapsed) {
    if (daysElapsed <= 2) {
      return const [
        SuggestedQuestion(label: '세안해도 돼요?', question: '오늘 세안해도 되나요?'),
        SuggestedQuestion(label: '화장은 언제부터?', question: '화장은 언제부터 가능한가요?'),
        SuggestedQuestion(label: '잘 때 주의사항', question: '오늘 잘 때 조심할 게 있나요?'),
        SuggestedQuestion(label: '부위 만져도 돼요?', question: '관리 부위를 만져도 되나요?'),
        SuggestedQuestion(label: '운동은 언제부터?', question: '운동은 언제부터 가능한가요?'),
        SuggestedQuestion(label: '술은 언제부터?', question: '술은 언제부터 마셔도 되나요?'),
      ];
    } else if (daysElapsed <= 7) {
      return const [
        SuggestedQuestion(label: '운동해도 될까요?', question: '운동해도 괜찮을까요?'),
        SuggestedQuestion(label: '사우나 가능?', question: '사우나는 언제부터 가능한가요?'),
        SuggestedQuestion(label: '음주해도 돼요?', question: '음주해도 괜찮을까요?'),
        SuggestedQuestion(label: '화장품 사용?', question: '평소 화장품을 사용해도 되나요?'),
        SuggestedQuestion(label: '마사지 가능?', question: '마사지 받아도 되나요?'),
        SuggestedQuestion(label: '다른 피부관리?', question: '다른 피부관리를 받아도 되나요?'),
      ];
    } else {
      return const [
        SuggestedQuestion(label: '스킨케어 복귀?', question: '일상 스킨케어로 돌아가도 되나요?'),
        SuggestedQuestion(label: '효과는 언제?', question: '효과는 언제부터 느껴지나요?'),
        SuggestedQuestion(label: '효과 판단 시점?', question: '지금부터 효과를 판단해도 되나요?'),
        SuggestedQuestion(label: '다음 시술 언제?', question: '다음 시술은 언제 가능한가요?'),
        SuggestedQuestion(label: '재시술 주기', question: '재시술 주기가 궁금해요'),
        SuggestedQuestion(label: '효과 유지법', question: '효과를 오래 유지하려면 어떻게 해야 하나요?'),
      ];
    }
  }

  String _brandLabel(String? brand) {
    if (brand == null || brand.isEmpty) return '';
    final b = brand.toUpperCase();
    if (b.contains('AMRED')) return '엠레드';
    if (b.contains('DERNA')) return '더나';
    if (b.contains('WIM')) return '윔';
    return brand;
  }

  Color _brandColor(String? brand) {
    if (brand == null) return AppColors.whsBlack;
    final b = brand.toUpperCase();
    if (b.contains('AMRED')) return AppColors.amred;
    if (b.contains('DERNA')) return AppColors.derna;
    if (b.contains('WIM')) return AppColors.wim;
    return AppColors.whsBlack;
  }

  void _onSuggestionTap(String suggestion) {
    _sendMessage(suggestion);
  }

  void _showCareSelection() {
    setState(() {
      _messages.add(ChatMessage(
        type: MessageType.text,
        text: '다른 관리 관련해서 질문이 있어요',
        isUser: true,
      ));
      _messages.add(const ChatMessage(
        type: MessageType.text,
        text: '어떤 관리의 사후관리가 궁금하신가요?',
        isUser: false,
      ));
      _messages.add(ChatMessage(
        type: MessageType.careSelection,
        isUser: false,
        cares: _recentCares,
      ));
    });
    _scrollToBottom();
  }

  void _onCareSelected(CareRecordItem care) {
    final daysElapsed = DateTime.now().difference(DateTime.parse(care.careDate)).inDays;
    final brandName = _brandLabel(care.brand);
    final displayName = brandName.isNotEmpty ? '$brandName ${care.careName}' : care.careName;

    setState(() {
      _selectedCare = care;

      _messages.add(ChatMessage(
        type: MessageType.text,
        text: displayName,
        isUser: true,
      ));
      _messages.add(ChatMessage(
        type: MessageType.text,
        text: '$displayName은 관리 후 $daysElapsed일차예요.\n어떤 점이 궁금하신가요?',
        isUser: false,
      ));
      _messages.add(ChatMessage(
        type: MessageType.suggestions,
        isUser: false,
        suggestions: _getSuggestedQuestions(daysElapsed),
      ));
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(type: MessageType.text, text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _aftercareService.askQuestion(QuestionRequest(
        careRecordId: _selectedCare?.careRecordId,
        category: _inferCategory(text),
        question: text,
      ));

      if (!mounted) return;
      setState(() {
        _isTyping = false;
        if (response.status == 'answered' && response.answer != null) {
          _messages.add(ChatMessage(
            type: MessageType.text,
            text: response.answer!,
            isUser: false,
            consultationLevel: response.consultationLevel,
          ));
        } else if (response.status == 'out_of_scope' || response.status == 'expert_required') {
          _messages.add(ChatMessage(
            type: MessageType.text,
            text: response.message ?? '해당 질문은 전문가 상담이 필요합니다.\n시술받은 병원에 문의해주세요.',
            isUser: false,
            consultationLevel: response.consultationLevel,
          ));
        }
        // 답변 후 추가 질문 유도
        final daysElapsed = _selectedCare != null
            ? DateTime.now().difference(DateTime.parse(_selectedCare!.careDate)).inDays
            : 0;
        _messages.add(ChatMessage(
          type: MessageType.suggestions,
          isUser: false,
          suggestions: _getSuggestedQuestions(daysElapsed),
        ));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(const ChatMessage(
          type: MessageType.text,
          text: '답변을 생성하지 못했습니다. 잠시 후 다시 시도해주세요.',
          isUser: false,
        ));
      });
    }
    _scrollToBottom();
  }

  String _inferCategory(String question) {
    final q = question.toLowerCase();
    if (q.contains('세안') || q.contains('샤워')) return '세안·샤워';
    if (q.contains('화장') || q.contains('렌즈') || q.contains('메이크업')) return '화장·렌즈';
    if (q.contains('운동') || q.contains('사우나') || q.contains('찜질')) return '운동·사우나';
    if (q.contains('음주') || q.contains('술') || q.contains('흡연') || q.contains('담배')) return '음주·흡연';
    if (q.contains('화장품') || q.contains('성분') || q.contains('레티놀') || q.contains('자외선')) return '화장품·성분';
    return '증상';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.whsBlack),
                        ),
                        const SizedBox(width: 12),
                        SvgPicture.asset(
                          'assets/svg/ic_ai_ask.svg',
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AI 사후관리 챗봇',
                          style: TextStyle(
                            color: AppColors.whsBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chat messages
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.whsBlack))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            itemCount: _messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < _messages.length) {
                                return _buildMessageWidget(_messages[index]);
                              }
                              return const _TypingIndicator();
                            },
                          ),
                  ),

                  // Input
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: '궁금한 점을 물어보세요',
                                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                              ),
                              style: const TextStyle(color: AppColors.whsBlack, fontSize: 14),
                              onSubmitted: _sendMessage,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _sendMessage(_controller.text),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.whsBlack,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/ic_send.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                currentIndex: 2,
                onTap: (i) {
                  if (i == 2) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainScreen(initialTab: i)),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 메시지 위젯 분기 ───

  Widget _buildMessageWidget(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return _MessageBubble(message: message);
      case MessageType.suggestions:
        return _buildSuggestionChips(message.suggestions ?? []);
      case MessageType.careSelection:
        return _buildCareCards(message.cares ?? []);
    }
  }

  Widget _buildSuggestionChips(List<SuggestedQuestion> suggestions) {
    return _SuggestionChipsWidget(
      suggestions: suggestions,
      onSuggestionTap: _onSuggestionTap,
      onOtherCareTap: _showCareSelection,
      showOtherCareButton: _recentCares.length > 1,
    );
  }

  Widget _buildCareCards(List<CareRecordItem> cares) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cares.map((care) {
            final color = _brandColor(care.brand);
            final label = _brandLabel(care.brand);
            final displayName = label.isNotEmpty ? '$label ${care.careName}' : care.careName;
            return GestureDetector(
              onTap: () => _onCareSelected(care),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorDot(color: color, size: 8),
                    const SizedBox(width: 6),
                    Text(
                      displayName,
                      style: const TextStyle(color: AppColors.whsBlack, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── 메시지 버블 ───

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: widget.message.isUser ? _buildUserBubble() : _buildAiBubble(),
        ),
      ),
    );
  }

  Widget _buildUserBubble() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 48),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.whsBlack,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.message.text ?? '',
              style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiBubble() {
    final level = widget.message.consultationLevel ?? 'NONE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.message.text ?? '',
                  style: const TextStyle(color: AppColors.whsBlack, fontSize: 14, height: 1.4),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        if (level == 'RECOMMENDED') _buildConsultationCard(
          message: '정확한 확인이 필요한 부분은 관리받은 곳에 문의해주세요.',
          buttonText: '문의하기 >',
          isUrgent: false,
        ),
        if (level == 'URGENT') _buildConsultationCard(
          message: '현재 증상은 직접 확인이 필요한 내용이에요.\n관리받은 곳에 빠르게 문의해주세요.',
          buttonText: '관리받은 곳에 문의하기',
          isUrgent: true,
        ),
      ],
    );
  }

  Widget _buildConsultationCard({
    required String message,
    required String buttonText,
    required bool isUrgent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 48),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUrgent ? const Color(0xFFFFF8F0) : const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUrgent ? const Color(0xFFE8D5C0) : AppColors.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isUrgent ? const Color(0xFF8B5E34) : AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // TODO: 실제 전화/채팅 연결 기능 구현
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFF3B3B3B) : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: isUrgent ? null : Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: isUrgent ? AppColors.white : AppColors.whsBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 타이핑 인디케이터 ───

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.25;
                    final value = (_controller.value - delay).clamp(0.0, 1.0);
                    final opacity = 0.3 + 0.7 * (0.5 + 0.5 * _sin(value * 2 * 3.14159));
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _sin(double x) {
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }
}

// ─── 추천 질문 칩 (가로 스크롤 compact) ───

class _SuggestionChipsWidget extends StatefulWidget {
  final List<SuggestedQuestion> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onOtherCareTap;
  final bool showOtherCareButton;

  const _SuggestionChipsWidget({
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onOtherCareTap,
    required this.showOtherCareButton,
  });

  @override
  State<_SuggestionChipsWidget> createState() => _SuggestionChipsWidgetState();
}

class _SuggestionChipsWidgetState extends State<_SuggestionChipsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final sq = widget.suggestions[index];
                return GestureDetector(
                  onTap: () => widget.onSuggestionTap(sq.question),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      sq.label,
                      style: const TextStyle(
                        color: AppColors.whsBlack,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.showOtherCareButton) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: widget.onOtherCareTap,
              child: const Text(
                '다른 관리 질문하기 >',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
