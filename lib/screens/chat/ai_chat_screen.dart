import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../main_screen.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _showSuggestions = true;
  bool _showCareSelection = false;
  bool _isTyping = false;

  final List<String> _suggestions = [
    '오늘 화장해도 되나요?',
    '오늘 화장해도 되나요?',
    '오늘 화장해도 되나요?',
    '오늘 화장해도 되나요?',
    '다른 관리 관련해서 질문이 있어요',
  ];

  final List<_CareOption> _careOptions = [
    _CareOption('엠레드 울쎄라', AppColors.amred),
    _CareOption('더나 입술 필러', AppColors.derna),
    _CareOption('윔 지방분해', AppColors.wim),
  ];

  @override
  void initState() {
    super.initState();
    // 초기 AI 메시지
    _messages.add(_ChatMessage(
      text: '안녕하세요, 원두님.\n최근에 받은 울쎄라는 현재 관리 후 3일차예요.\n사후관리와 관련해 어떤 점이 궁금하신가요?',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _showSuggestions = false;
      _showCareSelection = false;
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 더미 AI 응답 (나중에 API로 교체)
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        if (text.contains('다른 관리')) {
          _messages.add(_ChatMessage(
            text: '어떤 관리의 사후관리가 궁금하신가요?',
            isUser: false,
          ));
          _showCareSelection = true;
        } else {
          _messages.add(_ChatMessage(
            text: '안녕하세요, 원두님.\n최근에 받은 울쎄라는 현재 관리 후 3일차예요.\n사후관리와 관련해 어떤 점이 궁금하신가요?',
            isUser: false,
          ));
        }
      });
      _scrollToBottom();
    });
  }

  void _selectCare(_CareOption care) {
    _sendMessage('${care.name} 관련해서 질문이 있어요');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 콘텐츠
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
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      itemCount: _messages.length
                          + (_isTyping ? 1 : 0)
                          + (_showSuggestions ? 1 : 0)
                          + (_showCareSelection ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return _MessageBubble(
                            key: ValueKey(index),
                            message: _messages[index],
                          );
                        }
                        int offset = _messages.length;
                        if (_isTyping) {
                          if (index == offset) return const _TypingIndicator();
                          offset++;
                        }
                        if (_showSuggestions && index == offset) {
                          return _buildSuggestions();
                        }
                        if (_showCareSelection && index == offset) {
                          return _buildCareSelection();
                        }
                        return const SizedBox();
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

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions.map((s) {
            return GestureDetector(
              onTap: () => _sendMessage(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  s,
                  style: const TextStyle(color: AppColors.whsBlack, fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCareSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _careOptions.map((care) {
            return GestureDetector(
              onTap: () => _selectCare(care),
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
                    ColorDot(color: care.color, size: 8),
                    const SizedBox(width: 6),
                    Text(
                      care.name,
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

// ─── 메시지 버블 (슬라이드+페이드 애니메이션 + 말풍선 꼬리 + 아바타) ───

class _MessageBubble extends StatefulWidget {
  final _ChatMessage message;

  const _MessageBubble({super.key, required this.message});

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
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
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
              widget.message.text,
              style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiBubble() {
    return Row(
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
              widget.message.text,
              style: const TextStyle(color: AppColors.whsBlack, fontSize: 14, height: 1.4),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
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
    // 간단한 sin 근사 (dart:math 없이)
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}

class _CareOption {
  final String name;
  final Color color;
  const _CareOption(this.name, this.color);
}
