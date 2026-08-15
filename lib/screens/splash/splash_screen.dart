import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _logoController;

  late Animation<double> _circleAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 검은 원 확장 (중앙에서)
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _circleAnimation = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    );

    // 로고: 줌인 블러
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _blurAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // 흰 배경 잠깐 보여준 후
    await Future.delayed(const Duration(milliseconds: 500));
    _circleController.forward(); // 검은 원 확장

    await Future.delayed(const Duration(milliseconds: 600));
    _logoController.forward(); // 로고 줌인 블러

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxRadius = (screenSize.width + screenSize.height) * 1.5;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // 검은 원 (왼쪽 하단에서 확장하여 화면 전체 덮음)
          AnimatedBuilder(
            animation: _circleAnimation,
            builder: (context, child) {
              final size = maxRadius * _circleAnimation.value;
              return Positioned(
                left: -size / 2 + screenSize.width * 0.1,
                bottom: -size / 2 + screenSize.height * 0.1,
                child: Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: AppColors.whsBlack,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // 로고 (줌인 블러)
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Image.asset(
                        'assets/images/logo_white.png',
                        width: 220,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
