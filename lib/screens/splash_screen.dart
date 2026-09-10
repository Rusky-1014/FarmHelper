import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/floating_leaves.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _gradientController;
  late Animation<double> _progressAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _gradientAnim;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(_gradientController);

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _progressAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.85, curve: Curves.easeInOut),
    );

    _fadeAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _mainController.forward();

    Future.delayed(const Duration(milliseconds: 2900), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F4F0),
      body: Stack(
        children: [
          // Floating leaves background
          FloatingLeavesBackground(isDark: isDark),

          // Animated gradient blobs
          AnimatedBuilder(
            animation: _gradientAnim,
            builder: (_, __) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + _gradientAnim.value * 40,
                    left: -60 + _gradientAnim.value * 30,
                    child: _GradientBlob(
                      color: const Color(0xFF2DBD6E),
                      size: 300,
                      opacity: isDark ? 0.12 : 0.08,
                    ),
                  ),
                  Positioned(
                    bottom: -80 + _gradientAnim.value * -20,
                    right: -40,
                    child: _GradientBlob(
                      color: const Color(0xFF1A8A4A),
                      size: 260,
                      opacity: isDark ? 0.10 : 0.06,
                    ),
                  ),
                ],
              );
            },
          ),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, _) {
                return Column(
                  children: [
                    const Spacer(flex: 3),

                    // Brand logo
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: _BrandLogo(isDark: isDark),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Farm',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Helper',
                                  style: TextStyle(
                                    color: Color(0xFF2DBD6E),
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DBD6E).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF2DBD6E).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'AI Plant Disease Detection',
                              style: TextStyle(
                                color: const Color(0xFF2DBD6E),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _progressAnim.value,
                              backgroundColor:
                                  (isDark ? Colors.white : Colors.black)
                                      .withOpacity(0.08),
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF2DBD6E)),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Loading AI models...',
                            style: TextStyle(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.35),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Brand Logo ────────────────────────────────────────────────────────────────

class _BrandLogo extends StatelessWidget {
  final bool isDark;
  const _BrandLogo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2DBD6E), Color(0xFF1A8A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2DBD6E).withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle ring
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          // Leaf icon
          const Text('🌿', style: TextStyle(fontSize: 54)),
        ],
      ),
    );
  }
}

// ── Gradient Blob ─────────────────────────────────────────────────────────────

class _GradientBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _GradientBlob(
      {required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0)],
        ),
      ),
    );
  }
}