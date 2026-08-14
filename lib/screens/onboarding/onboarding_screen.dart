import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const Color _buttonColor = Color(0xFF3B3B3C);

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      image: 'assets/images/img_onboarding_1.png',
      title: '회복은 관리에서 시작됩니다',
      lines: ['시술 후의 시간도 케어의 일부에요.', 'WHS After Mate가 그 여정을 함께합니다'],
      style: _PageStyle.fullCoverTopText,
    ),
    _OnboardingData(
      image: 'assets/images/img_onboarding_2.png',
      title: '오늘 필요한 관리를 알려드려요',
      lines: ['시술 종류와 경과일에 맞춰', '지금 필요한 사후관리 방법을 안내합니다'],
      style: _PageStyle.centeredImageBottomText,
    ),
    _OnboardingData(
      image: 'assets/images/img_onboarding_3.png',
      title: '시술 이후에도 계속 연결됩니다',
      lines: ['관리 기록부터 궁금한 점과 다음 케어까지,', 'WHS After Mate에서 한 번에 확인하세요'],
      style: _PageStyle.fullCoverBottomText,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => _buildPage(_pages[i]),
          ),

          // 하단 인디케이터 + 버튼
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Column(
              children: [
                // 도트 인디케이터
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.white
                            : AppColors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage == 0 ? AppColors.whsBlack : _buttonColor,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? '시작하기' : '다음',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingData page) {
    switch (page.style) {
      case _PageStyle.fullCoverTopText:
        return _buildFullCoverTop(page);
      case _PageStyle.centeredImageBottomText:
        return _buildCenteredImage(page);
      case _PageStyle.fullCoverBottomText:
        return _buildFullCoverBottom(page);
    }
  }

  // 1페이지: 풀스크린 이미지 + 상단 텍스트 (검정색+그림자)
  Widget _buildFullCoverTop(_OnboardingData page) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(page.image, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          top: MediaQuery.of(context).padding.top + 120,
          child: Column(
            children: [
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.whsBlack,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...page.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      line,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.whsBlack.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // 2페이지: 검정 배경 + 이미지 중앙 + 하단 텍스트
  Widget _buildCenteredImage(_OnboardingData page) {
    return Stack(
      children: [
        // 검정 배경
        Container(color: Colors.black),
        // 이미지 (상단~중앙)
        Positioned(
          top: MediaQuery.of(context).padding.top + 40,
          left: 32,
          right: 32,
          bottom: 280,
          child: Image.asset(
            page.image,
            fit: BoxFit.contain,
          ),
        ),
        // 텍스트 (3페이지와 동일한 위치)
        Positioned(
          left: 24,
          right: 24,
          bottom: 180,
          child: Column(
            children: [
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              ...page.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      line,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // 3페이지: 풀스크린 이미지 + 하단 텍스트 (흰색)
  Widget _buildFullCoverBottom(_OnboardingData page) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(page.image, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.3, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 180,
          child: Column(
            children: [
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              ...page.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      line,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

enum _PageStyle { fullCoverTopText, centeredImageBottomText, fullCoverBottomText }

class _OnboardingData {
  final String image;
  final String title;
  final List<String> lines;
  final _PageStyle style;

  const _OnboardingData({
    required this.image,
    required this.title,
    required this.lines,
    required this.style,
  });
}
