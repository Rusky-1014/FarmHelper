import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/localization_service.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_border_card.dart';
import 'camera_screen.dart';
import 'farmer_profile_screen.dart';
import 'history_screen.dart';
import 'about_us_screen.dart'; // <-- Added import for the new screen
import 'ai_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeInController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut);
    // Refresh farmer name on every visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshFarmerName();
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    super.dispose();
  }

  void _showLanguagePicker(BuildContext context, AppProvider ap, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(
        currentLang: ap.language,
        isDark: isDark,
        onSelect: (lang) {
          ap.setLanguage(lang);
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final isDark = ap.isDarkMode;
    final farmerName = ap.farmerName;
    final bg = ap.bgColor;
    final textColor = ap.textColor;
    final subText = ap.subTextColor;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Floating leaves
          FloatingLeavesBackground(isDark: isDark),

          // Gradient blobs
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2DBD6E).withOpacity(isDark ? 0.10 : 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Top Bar ──────────────────────────────────────
                    Row(
                      children: [
                        // Brand logo small
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2DBD6E), Color(0xFF1A8A4A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF2DBD6E).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🌿', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: 'Farm',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'Helper',
                                    style: TextStyle(
                                      color: Color(0xFF2DBD6E),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ]),
                              ),
                              Text(
                                L.t('tagline'),
                                style: TextStyle(color: subText, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        // Language button
                        GestureDetector(
                          onTap: () =>
                              _showLanguagePicker(context, ap, isDark),
                          child: _TopBarBtn(
                            isDark: isDark,
                            child: Text(
                              _langFlag(ap.language),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Theme toggle
                        GestureDetector(
                          onTap: ap.toggleTheme,
                          child: _TopBarBtn(
                            isDark: isDark,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                isDark
                                    ? Icons.wb_sunny_rounded
                                    : Icons.nights_stay_rounded,
                                key: ValueKey(isDark),
                                color: isDark
                                    ? const Color(0xFFFFC107)
                                    : const Color(0xFF5C6BC0),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Greeting ──────────────────────────────────────
                    if (farmerName.isNotEmpty) ...[
                      GlassCard(
                        isDark: isDark,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2DBD6E).withOpacity(0.15),
                              ),
                              child: const Center(
                                child:
                                    Text('👨‍🌾', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${L.t('welcome_back')},',
                                  style: TextStyle(
                                    color: subText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  farmerName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2DBD6E).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '🌱 Active',
                                style: TextStyle(
                                  color: Color(0xFF2DBD6E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Hero ───────────────────────────────────────────
                    // NEW PROFESSIONAL TAGLINE
                    Text(
                      L.t('hero_title'),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 44, // Slightly adjusted for elegance
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      L.t('hero_sub'),
                      style: TextStyle(
                        color: subText,
                        fontSize: 14,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Select crop label ─────────────────────────────
                    Text(
                      L.t('select_crop').toUpperCase(), // Ensures professional caps
                      style: TextStyle(
                        color: subText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800, // Slightly bolder for hierarchy
                        letterSpacing: 2,
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.smart_toy),
                        title: const Text('FarmHelper AI'),
                        subtitle: const Text(
                          'Ask agricultural questions offline',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AiAssistantScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 14),

                    // ── Mango Card ─────────────────────────────────────
                    AnimatedGradientBorder(
                      colors: const [
                        Color(0xFFF5A623),
                        Color(0xFFFFD700),
                        Color(0xFFF5A623),
                      ],
                      borderRadius: BorderRadius.circular(22),
                      child: _CropCard(
                        emoji: '🥭',
                        name: 'Mango',
                        description: '8 ${L.t('disease_classes')}',
                        accentColor: const Color(0xFFF5A623),
                        isDark: isDark,
                        diseases: const [
                          'Anthracnose',
                          'Bacterial Canker',
                          'Die Back',
                          'Gall Midge',
                          'Powdery Mildew',
                          'Sooty Mould',
                          '+ 2 more',
                        ],
                        onTap: () => Navigator.push(
                          context,
                          _slideRoute(const CameraScreen(crop: 'mango')),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Grape Card ─────────────────────────────────────
                    AnimatedGradientBorder(
                      colors: const [
                        Color(0xFF7B61FF),
                        Color(0xFFAD8BFF),
                        Color(0xFF7B61FF),
                      ],
                      borderRadius: BorderRadius.circular(22),
                      child: _CropCard(
                        emoji: '🍇',
                        name: 'Grape',
                        description: '4 ${L.t('disease_classes')}',
                        accentColor: const Color(0xFF7B61FF),
                        isDark: isDark,
                        diseases: const [
                          'Black Rot',
                          'ESCA',
                          'Leaf Blight',
                          'Healthy',
                        ],
                        onTap: () => Navigator.push(
                          context,
                          _slideRoute(const CameraScreen(crop: 'grape')),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── More section ───────────────────────────────────
                    Text(
                      L.t('more').toUpperCase(),
                      style: TextStyle(
                        color: subText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _NavRow(
                      emoji: '📋',
                      title: L.t('scan_history'),
                      subtitle: L.t('scan_history_sub'),
                      isDark: isDark,
                      textColor: textColor,
                      subText: subText,
                      onTap: () => Navigator.push(
                        context,
                        _slideRoute(const HistoryScreen()),
                      ),
                    ),

                    const SizedBox(height: 10),

                    _NavRow(
                      emoji: '👨‍🌾',
                      title: L.t('farmer_profile'),
                      subtitle: L.t('farmer_profile_sub'),
                      isDark: isDark,
                      textColor: textColor,
                      subText: subText,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          _slideRoute(const FarmerProfileScreen()),
                        );
                        if (mounted) {
                          ap.refreshFarmerName();
                        }
                      },
                    ),

                    const SizedBox(height: 40), // More breathing room for footer

                    // ── Footer ─────────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2DBD6E),
                                      Color(0xFF1A8A4A)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child:
                                      Text('🌿', style: TextStyle(fontSize: 10)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                L.t('powered_by'), // Or 'Powered by Wavelet Neural Networks'
                                style: TextStyle(
                                  color: subText.withOpacity(0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // NEW: Professional Copyright Line
                          Text(
                            '© All rights reserved to ASCII Labs, IIT Bhilai',
                            style: TextStyle(
                              color: subText.withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // NEW: About Us / Developed By Link
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context, _slideRoute(const AboutUsScreen()));
                            },
                            icon: Icon(Icons.code_rounded,
                                size: 16, color: subText.withOpacity(0.8)),
                            label: Text(
                              'About the Developers',
                              style: TextStyle(
                                color: subText.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              backgroundColor: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.04),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _langFlag(String lang) {
    switch (lang) {
      case 'hi':
        return '🇮🇳';
      case 'bn':
        return '🇧🇩';
      default:
        return '🇬🇧';
    }
  }

  PageRoute _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 380),
    );
  }
}

// ── Top Bar Button ─────────────────────────────────────────────────────────────

class _TopBarBtn extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _TopBarBtn({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ── Language Sheet ─────────────────────────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  final String currentLang;
  final bool isDark;
  final ValueChanged<String> onSelect;

  const _LanguageSheet({
    required this.currentLang,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? Colors.white54 : const Color(0xFF666666);

    final langs = [
      {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी', 'flag': '🇮🇳'},
      {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇧🇩'},
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '🌐  Language / भाषा / ভাষা',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              ...langs.map((lang) {
                final isSelected = lang['code'] == currentLang;
                return GestureDetector(
                  onTap: () => onSelect(lang['code']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2DBD6E).withOpacity(0.12)
                          : (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2DBD6E).withOpacity(0.5)
                            : (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.07),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang['flag']!,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang['native']!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              lang['name']!,
                              style: TextStyle(color: subText, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2DBD6E),
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 14),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Crop Card ──────────────────────────────────────────────────────────────────

class _CropCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final Color accentColor;
  final List<String> diseases;
  final VoidCallback onTap;
  final bool isDark;

  const _CropCard({
    required this.emoji,
    required this.name,
    required this.description,
    required this.accentColor,
    required this.diseases,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF888888);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: cardColor,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            description,
                            style: TextStyle(color: subText, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: diseases.map((d) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: accentColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          d,
                          style: TextStyle(
                            color: isDark ? accentColor.withAlpha(200) : accentColor.withAlpha(220),
                            fontSize: 10,
                            fontWeight: FontWeight.w700, // Made slightly bolder
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav Row ────────────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final Color textColor;
  final Color subText;

  const _NavRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    required this.textColor,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: subText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: subText.withOpacity(0.6), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}