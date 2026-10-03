import 'dart:io';
import 'package:flutter/material.dart';
import '../services/labels.dart';
import '../services/medicine_service.dart';
import '../services/ai_context_service.dart';
import 'ai_assistant_screen.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final String crop;
  final String disease;
  final double confidence;
  final List<double> allPredictions;

  const ResultScreen({
    super.key,
    required this.image,
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.allPredictions,
  });

  Color get _accentColor =>
      crop == 'mango' ? const Color(0xFFF5A623) : const Color(0xFF7B61FF);

  bool get _isHealthy => disease.toLowerCase() == 'healthy';

  Color get _statusColor =>
      _isHealthy ? Colors.green : const Color(0xFFFF4D4D);

  // ── Color analysis data per disease ─────────────────────────────────────────
  List<_ColorEntry> get _colorAnalysis {
    final data = <String, List<_ColorEntry>>{
      'Anthracnose': [
        _ColorEntry('Dark Brown', const Color(0xFF6B3A2A), 0.42),
        _ColorEntry('Black', const Color(0xFF1A1A1A), 0.28),
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.20),
        _ColorEntry('Yellow', const Color(0xFFFFEB3B), 0.10),
      ],
      'Bacterial Canker': [
        _ColorEntry('Orange-Brown', const Color(0xFFD2691E), 0.38),
        _ColorEntry('Yellow', const Color(0xFFFFEB3B), 0.25),
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.22),
        _ColorEntry('Dark', const Color(0xFF3E2723), 0.15),
      ],
      'Cutting Weevil': [
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.45),
        _ColorEntry('Brown', const Color(0xFF795548), 0.30),
        _ColorEntry('Yellow', const Color(0xFFFFEB3B), 0.15),
        _ColorEntry('Black', const Color(0xFF1A1A1A), 0.10),
      ],
      'Die Back': [
        _ColorEntry('Dark Brown', const Color(0xFF4E342E), 0.50),
        _ColorEntry('Black', const Color(0xFF1A1A1A), 0.30),
        _ColorEntry('Grey', const Color(0xFF9E9E9E), 0.12),
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.08),
      ],
      'Gall Midge': [
        _ColorEntry('Yellow-Green', const Color(0xFFCDDC39), 0.40),
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.30),
        _ColorEntry('Orange', const Color(0xFFFF9800), 0.20),
        _ColorEntry('Brown', const Color(0xFF795548), 0.10),
      ],
      'Powdery Mildew': [
        _ColorEntry('White-Grey', const Color(0xFFEEEEEE), 0.48),
        _ColorEntry('Light Green', const Color(0xFF8BC34A), 0.30),
        _ColorEntry('Grey', const Color(0xFF9E9E9E), 0.14),
        _ColorEntry('Yellow', const Color(0xFFFFEB3B), 0.08),
      ],
      'Sooty Mould': [
        _ColorEntry('Black', const Color(0xFF1A1A1A), 0.52),
        _ColorEntry('Dark Grey', const Color(0xFF424242), 0.28),
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.12),
        _ColorEntry('Brown', const Color(0xFF795548), 0.08),
      ],
      'Healthy': [
        _ColorEntry('Bright Green', const Color(0xFF4CAF50), 0.65),
        _ColorEntry('Dark Green', const Color(0xFF1B5E20), 0.22),
        _ColorEntry('Yellow-Green', const Color(0xFFCDDC39), 0.10),
        _ColorEntry('Brown (stem)', const Color(0xFF795548), 0.03),
      ],
      'Black Rot': [
        _ColorEntry('Black', const Color(0xFF1A1A1A), 0.45),
        _ColorEntry('Brown', const Color(0xFF6D4C41), 0.30),
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.15),
        _ColorEntry('Grey', const Color(0xFF9E9E9E), 0.10),
      ],
      'ESCA': [
        _ColorEntry('Yellow-Brown', const Color(0xFFBCAAA4), 0.40),
        _ColorEntry('Dark Brown', const Color(0xFF4E342E), 0.30),
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.20),
        _ColorEntry('Grey', const Color(0xFF9E9E9E), 0.10),
      ],
      'Leaf Blight': [
        _ColorEntry('Tan-Brown', const Color(0xFFD7CCC8), 0.38),
        _ColorEntry('Dark Brown', const Color(0xFF5D4037), 0.32),
        _ColorEntry('Green', const Color(0xFF4CAF50), 0.20),
        _ColorEntry('Yellow', const Color(0xFFFFEB3B), 0.10),
      ],
    };

    return data[disease] ??
        [
          _ColorEntry('Green', const Color(0xFF4CAF50), 0.50),
          _ColorEntry('Brown', const Color(0xFF795548), 0.25),
          _ColorEntry('Yellow', const Color(0xFFFFEB3B), 0.15),
          _ColorEntry('Dark', const Color(0xFF1A1A1A), 0.10),
        ];
  }

  // ── Disease tips ─────────────────────────────────────────────────────────────
  List<String> get _diseaseTips {
    const tips = <String, List<String>>{
      'Anthracnose': [
        '🌬️ Improve air circulation between plants',
        '🚿 Avoid overhead watering',
        '🍂 Remove and destroy infected leaves',
        '☀️ Prune to let sunlight penetrate canopy',
      ],
      'Bacterial Canker': [
        '✂️ Prune infected branches 10cm below lesion',
        '🔥 Burn all pruned material immediately',
        '🧴 Seal cuts with Bordeaux paste',
        '🌧️ Avoid pruning in wet weather',
      ],
      'Cutting Weevil': [
        '🍂 Remove fallen leaves from base of tree',
        '🪲 Use sticky traps around trunk',
        '🌅 Spray insecticide at bud burst stage',
        '🔍 Inspect new shoots weekly',
      ],
      'Die Back': [
        '✂️ Prune well below visible infection',
        '🔥 Burn all pruned wood',
        '💧 Avoid water stress during dry periods',
        '🌱 Boost tree immunity with potassium fertilizer',
      ],
      'Gall Midge': [
        '🍃 Destroy infested shoot tips promptly',
        '🌸 Spray at early bud burst stage',
        '🔁 Repeat spray every 15 days',
        '🌿 Encourage natural predators in orchard',
      ],
      'Powdery Mildew': [
        '🌬️ Increase air circulation',
        '🌡️ Avoid spraying sulfur above 35°C',
        '✂️ Prune dense inner branches',
        '🚿 Water at base, not overhead',
      ],
      'Sooty Mould': [
        '🐛 Treat the underlying mealybug / scale insect first',
        '🍃 Wipe leaves with dilute neem solution',
        '✂️ Thin canopy to reduce honeydew buildup',
        '🌿 Use neem oil spray weekly until cleared',
      ],
      'Healthy': [
        '💧 Maintain regular irrigation schedule',
        '🌱 Apply balanced NPK fertilizer seasonally',
        '✂️ Prune dead wood after harvest',
        '🔍 Inspect leaves weekly for early signs',
      ],
      'Black Rot': [
        '🍇 Remove and destroy all mummified berries',
        '✂️ Prune in dry weather only',
        '🌬️ Ensure good canopy airflow',
        '🧴 Apply fungicide before bloom stage',
      ],
      'ESCA': [
        '✂️ Seal all pruning wounds immediately',
        '🌿 Apply Trichoderma bio-agent at pruning',
        '🔥 Remove severely infected vines',
        '💧 Avoid water stress; drip irrigate',
      ],
      'Leaf Blight': [
        '🍃 Rake and destroy fallen leaves',
        '🔁 Alternate fungicides to prevent resistance',
        '🌬️ Improve row spacing for air circulation',
        '🌧️ Avoid spraying during rain',
      ],
    };

    return tips[disease] ??
        [
          '🔍 Consult your local agronomist',
          '📸 Take more leaf samples for analysis',
          '💧 Maintain proper irrigation',
        ];
  }

  @override
  Widget build(BuildContext context) {
    // ── Send the scan result to the Gemma AI context ─────────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AIContextService.setDiseaseContext(
        cropName: crop,
        diseaseName: disease,
        diseaseConfidence: confidence,
      );
    });

    final labels = cropLabels[crop]!;
    final medicine = MedicineService.getMedicine(crop, disease);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFF0D1117),
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              title: Text(
                'SCAN RESULT',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
              pinned: true,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image ────────────────────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Image.file(
                            image,
                            height: 230,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isHealthy
                                        ? Icons.check_circle
                                        : Icons.warning_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isHealthy
                                        ? 'HEALTHY'
                                        : 'DISEASE DETECTED',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Primary Result Card ──────────────────────────────────
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                crop == 'mango' ? '🥭' : '🍇',
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    crop.toUpperCase(),
                                    style: TextStyle(
                                      color: _accentColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const Text(
                                    'Leaf Analysis',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            disease,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Confidence',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 11,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: confidence,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.08),
                                        valueColor:
                                            AlwaysStoppedAnimation(_accentColor),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                '${(confidence * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: _accentColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Color Analysis ──────────────────────────────────────
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _accentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.palette_rounded,
                                  color: _accentColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'COLOR ANALYSIS',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ..._colorAnalysis.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: entry.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.label,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${(entry.value * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: entry.value,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.06),
                                      valueColor:
                                          AlwaysStoppedAnimation(entry.color),
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── All Class Probabilities ─────────────────────────────
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ALL CLASS PROBABILITIES',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...List.generate(labels.length, (i) {
                            final pct = allPredictions[i];
                            final isTop = i == _argmax(allPredictions);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          labels[i],
                                          style: TextStyle(
                                            color: isTop
                                                ? Colors.white
                                                : Colors.white60,
                                            fontSize: 13,
                                            fontWeight: isTop
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${(pct * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: isTop
                                              ? _accentColor
                                              : Colors.white38,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.06),
                                      valueColor: AlwaysStoppedAnimation(
                                        isTop
                                            ? _accentColor
                                            : Colors.white.withOpacity(0.2),
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Treatment / Healthy card ────────────────────────────
                    if (!_isHealthy)
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.medical_services_rounded,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'TREATMENT',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              label: 'Medicine',
                              value: medicine.name,
                            ),
                            _InfoRow(
                              label: 'Dosage',
                              value: medicine.dosage,
                            ),
                            _InfoRow(
                              label: 'Frequency',
                              value: medicine.frequency,
                            ),
                            if (medicine.notes.isNotEmpty)
                              _InfoRow(
                                label: 'Notes',
                                value: medicine.notes,
                              ),
                          ],
                        ),
                      ),

                    if (_isHealthy) ...[
                      _GlassCard(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                color: Colors.green,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Leaf is Healthy! 🎉',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'No treatment needed. Continue regular care.',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // ── Disease / Care Tips ──────────────────────────────────
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF2DBD6E).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_rounded,
                                  color: Color(0xFF2DBD6E),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'TIPS & CARE',
                                style: TextStyle(
                                  color: Color(0xFF2DBD6E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ..._diseaseTips.map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                tip,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Ask AI about this result ─────────────────────────────
                    GestureDetector(
                      onTap: () {
                        AIContextService.setDiseaseContext(
                          cropName: crop,
                          diseaseName: disease,
                          diseaseConfidence: confidence,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AiAssistantScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _accentColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.smart_toy_outlined,
                                color: _accentColor, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'ASK FARMHELPER AI',
                              style: TextStyle(
                                color: _accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Scan again button ────────────────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'SCAN ANOTHER LEAF',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _argmax(List<double> vals) {
    int idx = 0;

    for (int i = 1; i < vals.length; i++) {
      if (vals[i] > vals[idx]) {
        idx = i;
      }
    }

    return idx;
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _ColorEntry {
  final String label;
  final Color color;
  final double value;

  const _ColorEntry(
    this.label,
    this.color,
    this.value,
  );
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}