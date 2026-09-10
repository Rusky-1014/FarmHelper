import 'dart:math';
import 'package:flutter/material.dart';

class FloatingLeavesBackground extends StatefulWidget {
  final bool isDark;
  const FloatingLeavesBackground({super.key, required this.isDark});

  @override
  State<FloatingLeavesBackground> createState() =>
      _FloatingLeavesBackgroundState();
}

class _FloatingLeavesBackgroundState extends State<FloatingLeavesBackground>
    with TickerProviderStateMixin {
  final List<_Leaf> _leaves = [];
  late AnimationController _controller;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _spawnLeaves();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateLeaves)..repeat();
  }

  void _spawnLeaves() {
    for (int i = 0; i < 12; i++) {
      _leaves.add(_Leaf(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: 8 + _rng.nextDouble() * 14,
        speed: 0.00012 + _rng.nextDouble() * 0.00018,
        drift: (_rng.nextDouble() - 0.5) * 0.0004,
        opacity: 0.04 + _rng.nextDouble() * 0.07,
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.015,
        emoji: _rng.nextBool() ? '🍃' : '🌿',
      ));
    }
  }

  void _updateLeaves() {
    if (!mounted) return;
    setState(() {
      for (final leaf in _leaves) {
        leaf.y -= leaf.speed;
        leaf.x += leaf.drift;
        leaf.rotation += leaf.rotationSpeed;
        if (leaf.y < -0.05) {
          leaf.y = 1.05;
          leaf.x = _rng.nextDouble();
        }
        if (leaf.x < -0.05) leaf.x = 1.05;
        if (leaf.x > 1.05) leaf.x = -0.05;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _LeafPainter(_leaves, widget.isDark),
        ),
      ),
    );
  }
}

class _Leaf {
  double x, y, size, speed, drift, opacity, rotation, rotationSpeed;
  final String emoji;
  _Leaf({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.rotation,
    required this.rotationSpeed,
    required this.emoji,
  });
}

class _LeafPainter extends CustomPainter {
  final List<_Leaf> leaves;
  final bool isDark;
  _LeafPainter(this.leaves, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final leaf in leaves) {
      canvas.save();
      final dx = leaf.x * size.width;
      final dy = leaf.y * size.height;
      canvas.translate(dx, dy);
      canvas.rotate(leaf.rotation);
      paint.color =
          (isDark ? const Color(0xFF2DBD6E) : const Color(0xFF1A8A4A))
              .withOpacity(leaf.opacity);
      // Simple leaf shape
      final path = Path();
      final s = leaf.size;
      path.moveTo(0, -s);
      path.cubicTo(s * 0.6, -s * 0.6, s * 0.6, s * 0.2, 0, s * 0.4);
      path.cubicTo(-s * 0.6, s * 0.2, -s * 0.6, -s * 0.6, 0, -s);
      canvas.drawPath(path, paint);
      // Center vein
      final veinPaint = Paint()
        ..color = (isDark ? const Color(0xFF2DBD6E) : const Color(0xFF1A8A4A))
            .withOpacity(leaf.opacity * 0.5)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, -s * 0.8), Offset(0, s * 0.3), veinPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => true;
}