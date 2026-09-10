import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/glass_card.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final isDark = ap.isDarkMode;
    final bg = ap.bgColor;
    final textColor = ap.textColor;
    final subText = ap.subTextColor;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background animation
          FloatingLeavesBackground(isDark: isDark),

          // Decorative glow
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2DBD6E)
                        .withOpacity(isDark ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ── App Bar ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About Us',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Logo
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.03),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '🌱',
                              style: TextStyle(fontSize: 42),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Building AI for Agriculture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'We are student developers from IIT Bhilai passionate about applying Artificial Intelligence to solve real-world agricultural challenges. Through this Plant Disease Detection platform, we aim to empower farmers with accessible technology for early disease detection and better crop management.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subText,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Developers ────────────────────────
                        _DeveloperCard(
                          name: 'SHIVAM PANDEY',
                          role: 'AI & Flutter Developer',
                          institute: 'IIT Bhilai',
                          emoji: '🚀',
                          isDark: isDark,
                          textColor: textColor,
                          subText: subText,
                        ),

                        const SizedBox(height: 16),

                        _DeveloperCard(
                          name: 'ASHMITA DAS',
                          role: 'Software Developer & Research Enthusiast',
                          institute: 'IIT Bhilai',
                          emoji: '💻',
                          isDark: isDark,
                          textColor: textColor,
                          subText: subText,
                        ),

                        const SizedBox(height: 24),

                        // ── Mission Card ──────────────────────
                        GlassCard(
                          isDark: isDark,
                          padding: const EdgeInsets.all(22),
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '🌾',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Our Mission',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Agriculture remains the backbone of millions of lives. '
                                'Our mission is to bridge the gap between farmers and modern AI systems by building intelligent, easy-to-use tools that support disease detection, crop monitoring, and informed agricultural decisions.',
                                style: TextStyle(
                                  color: subText,
                                  fontSize: 14,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Vision Card ───────────────────────
                        GlassCard(
                          isDark: isDark,
                          padding: const EdgeInsets.all(22),
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '🤖',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Our Vision',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'We envision a future where Artificial Intelligence becomes accessible to every farmer, enabling smarter agriculture, higher productivity, and sustainable farming practices for generations to come.',
                                style: TextStyle(
                                  color: subText,
                                  fontSize: 14,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Footer ────────────────────────────
                        Text(
                          'Designed & Developed With Passion',
                          style: TextStyle(
                            color: subText.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'ASCII Labs • IIT Bhilai',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'AI for Farmers • Technology for Impact',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2DBD6E),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
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
}

class _DeveloperCard extends StatelessWidget {
  final String name;
  final String role;
  final String institute;
  final String emoji;
  final bool isDark;
  final Color textColor;
  final Color subText;

  const _DeveloperCard({
    required this.name,
    required this.role,
    required this.institute,
    required this.emoji,
    required this.isDark,
    required this.textColor,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF2DBD6E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: Color(0xFF2DBD6E),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@ $institute',
                  style: TextStyle(
                    color: subText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}