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
    });
    _controller.clear();
    _scrollToBottom();

    // 더미 AI 응답 (나중에 API로 교체)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
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
      bottomNavigationBar: BottomNavigationBar(
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
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/ic_home_outline.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/svg/ic_home_fill.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/ic_care_outline.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/svg/ic_care_fill.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            label: 'My Care',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/ic_ai_guide_outline.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/svg/ic_ai_guide_fill.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            label: 'AI 가이드',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/ic_settings_outline.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.navIconInactive, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/svg/ic_settings_fill.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.whsBlack, BlendMode.srcIn)),
            label: '설정',
          ),
        ],
      ),
      body: SafeArea(
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
                itemCount: _messages.length + (_showSuggestions ? 1 : 0) + (_showCareSelection ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _messages.length) {
                    return _buildMessageBubble(_messages[index]);
                  }
                  if (_showSuggestions && index == _messages.length) {
                    return _buildSuggestions();
                  }
                  if (_showCareSelection) {
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
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.whsBlack,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: AppColors.whsBlack, fontSize: 14, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
    );
  }

  Widget _buildCareSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
    );
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
