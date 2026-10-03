import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/localization_service.dart';
import '../services/image_service.dart';
import '../services/tensor_service.dart';
import '../services/tflite_service.dart';
import '../services/prediction_service.dart';
import '../services/labels.dart';
import '../services/history_service.dart';
import '../models/scan_record.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/scan_overlay.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/morphing_button.dart';

import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final String crop;
  const CameraScreen({super.key, required this.crop});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool modelLoaded = false;
  ButtonState _btnState = ButtonState.idle;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Color get _accentColor => widget.crop == 'mango'
      ? const Color(0xFFF5A623)
      : const Color(0xFF7B61FF);

  String get _cropEmoji => widget.crop == 'mango' ? '🥭' : '🍇';

  List<String> get _tips => widget.crop == 'mango'
      ? [
          '💧 Water deeply twice a week',
          '✂️ Prune after harvest',
          '🌱 Apply NPK in growing season',
          '🌧️ Watch for fungal signs after rain',
          '☀️ Needs full sun (6–8 hrs)',
        ]
      : [
          '🪴 Maintain trellis support',
          '✂️ Prune during dormancy',
          '💨 Control humidity to prevent mildew',
          '🍇 Thin clusters for better quality',
          '🌡️ Avoid waterlogging roots',
        ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadModel();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    TFLiteService.closeModel();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      await TFLiteService.loadModel(widget.crop);
      if (!mounted) return;
      setState(() => modelLoaded = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Model Error: $e')),
      );
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (image == null) return;
      setState(() => selectedImage = File(image.path));
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (image == null) return;
      setState(() => selectedImage = File(image.path));
    } catch (e) {
      debugPrint('Gallery Error: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (selectedImage == null || !modelLoaded) return;
    setState(() => _btnState = ButtonState.loading);

    try {
      final image = ImageService.preprocessImage(selectedImage!);
      final inputBuffer = TensorService.rgbBuffer(image);
      final int numClasses = widget.crop == 'mango' ? 8 : 4;
      final List<double> prediction =
          TFLiteService.predict(inputBuffer, numClasses);

      final int idx = PredictionService.argmax(prediction);
      final double conf = PredictionService.confidence(prediction);
      final String disease = cropLabels[widget.crop]![idx];

      if (conf < 0.45) {
        if (!mounted) return;
        setState(() => _btnState = ButtonState.idle);
        showDialog(
          context: context,
          builder: (_) {
            final ap = context.read<AppProvider>();
            final isDark = ap.isDarkMode;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                L.t('low_confidence'),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                'The model is only ${(conf * 100).toStringAsFixed(0)}% confident.\nTry a clearer, well-lit photo of the leaf.',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.65)
                      : const Color(0xFF555555),
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(L.t('retake'),
                      style: const TextStyle(color: Color(0xFF2DBD6E))),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToResult(disease, conf, prediction);
                  },
                  child: Text(
                    L.t('show_anyway'),
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black45,
                    ),
                  ),
                ),
              ],
            );
          },
        );
        return;
      }

      setState(() => _btnState = ButtonState.done);
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToResult(disease, conf, prediction);
    } catch (e) {
      debugPrint('Inference Error: $e');
      if (mounted) {
        setState(() => _btnState = ButtonState.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _navigateToResult(
      String disease, double conf, List<double> allPredictions) async {
    final record = ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      crop: widget.crop,
      disease: disease,
      confidence: conf,
      imagePath: selectedImage!.path,
      timestamp: DateTime.now(),
    );
    await HistoryService.saveRecord(record);

    if (!mounted) return;
    setState(() => _btnState = ButtonState.idle);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(
          image: selectedImage!,
          crop: widget.crop,
          disease: disease,
          confidence: conf,
          allPredictions: allPredictions,
        ),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final isDark = ap.isDarkMode;
    final bg = ap.bgColor;
    final textColor = ap.textColor;
    final subText = ap.subTextColor;
    final isAnalyzing = _btnState == ButtonState.loading;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          FloatingLeavesBackground(isDark: isDark),

          SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: ClipRRect(
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
                              child: Icon(Icons.arrow_back_ios_new,
                                  color: textColor, size: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '$_cropEmoji ${widget.crop.toUpperCase()} ${L.t('scanner')}',
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      // Model status pill — glassmorphic
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: modelLoaded
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: modelLoaded
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.orange.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: modelLoaded
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  modelLoaded ? L.t('ready') : L.t('loading'),
                                  style: TextStyle(
                                    color: modelLoaded
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Image Preview ─────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              colors: [
                                _accentColor.withOpacity(0.6),
                                _accentColor.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(27),
                              child: Container(
                                color: isDark
                                    ? const Color(0xFF161B22)
                                    : Colors.white,
                                child: selectedImage == null
                                    ? _buildEmptyState(textColor, subText)
                                    : Hero(
                                        tag: 'leaf_image',
                                        child: Image.file(
                                          selectedImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        // Scan corner brackets
                        if (selectedImage != null)
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: ScanCornerBrackets(color: _accentColor),
                            ),
                          ),

                        // Animated scan line (only when image selected)
                        if (selectedImage != null && !isAnalyzing)
                          Positioned(
                            top: 18,
                            left: 18,
                            right: 18,
                            bottom: 18,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: ScanOverlay(accentColor: _accentColor),
                            ),
                          ),

                        // Analyzing overlay — glassmorphic
                        if (isAnalyzing)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(27),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: Container(
                                  color: Colors.black.withOpacity(0.6),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation(
                                                    _accentColor),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        AnalyzingShimmerText(
                                          text: L.t('analyzing'),
                                          accentColor: _accentColor,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          L.t('ai_inference'),
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Growing Tips ──────────────────────────────────────
                if (selectedImage == null) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _tips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: _accentColor.withOpacity(0.25)),
                            ),
                            child: Text(
                              _tips[i],
                              style: TextStyle(
                                color: _accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── Buttons ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.camera_alt_rounded,
                              label: L.t('camera'),
                              color: _accentColor,
                              isDark: isDark,
                              onTap: isAnalyzing ? null : _captureImage,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.photo_library_rounded,
                              label: L.t('gallery'),
                              color: isDark
                                  ? Colors.white.withOpacity(0.10)
                                  : Colors.black.withOpacity(0.07),
                              isDark: isDark,
                              textColor:
                                  isDark ? Colors.white70 : Colors.black54,
                              onTap: isAnalyzing ? null : _pickFromGallery,
                            ),
                          ),
                        ],
                      ),
                      if (selectedImage != null) ...[
                        const SizedBox(height: 12),
                        MorphingAnalyzeButton(
                          state: _btnState,
                          accentColor: _accentColor,
                          label: L.t('analyze_leaf'),
                          onTap: _analyzeImage,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subText) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withOpacity(0.1),
                border: Border.all(
                    color: _accentColor.withOpacity(0.3), width: 2),
              ),
              child: Center(
                  child: Text(_cropEmoji,
                      style: const TextStyle(fontSize: 40))),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            L.t('capture_leaf'),
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            L.t('use_camera_gallery'),
            style: TextStyle(color: subText, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor ?? Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}