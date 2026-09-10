import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';

class ScanOverlay extends StatefulWidget {
  final Color accentColor;
  const ScanOverlay({super.key, required this.accentColor});

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scanAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scanAnim,
      builder: (_, __) {
        return CustomPaint(
          painter: _ScanPainter(
            progress: _scanAnim.value,
            color: widget.accentColor,
          ),
        );
      },
    );
  }
}

class _ScanPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ScanPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;

    // Glow line
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withOpacity(0),
          color.withOpacity(0.9),
          color.withOpacity(1),
          color.withOpacity(0.9),
          color.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 2, size.width, 4))
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, y - 1.5, size.width, 3), glowPaint);

    // Soft gradient trail below line
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.08),
          color.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, y, size.width, 40))
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, y, size.width, 40), trailPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Corner brackets ──────────────────────────────────────────────────────────

class ScanCornerBrackets extends StatelessWidget {
  final Color color;
  const ScanCornerBrackets({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerPainter(color),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    const r = 6.0;

    void drawCorner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y + dy * len), Offset(x, y + dy * r), paint);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x + dx * r, y + dy * r),
          width: r * 2,
          height: r * 2,
        ),
        dy < 0 ? (dx < 0 ? 0 : pi) : (dx < 0 ? pi * 1.5 : pi * 0.5),
        pi * 0.5 * dx * dy * -1,
        false,
        paint,
      );
      canvas.drawLine(Offset(x + dx * r, y), Offset(x + dx * len, y), paint);
    }

    drawCorner(0, 0, 1, 1);
    drawCorner(size.width, 0, -1, 1);
    drawCorner(0, size.height, 1, -1);
    drawCorner(size.width, size.height, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}