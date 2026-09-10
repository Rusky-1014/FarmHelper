import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiBurst extends StatefulWidget {
  final bool trigger;
  const ConfettiBurst({super.key, required this.trigger});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.trigger) _burst();
  }

  @override
  void didUpdateWidget(ConfettiBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) _burst();
  }

  void _burst() {
    _particles.clear();
    for (int i = 0; i < 60; i++) {
      _particles.add(_Particle(
        x: 0.5,
        y: 0.3,
        vx: (_rng.nextDouble() - 0.5) * 0.012,
        vy: -0.006 - _rng.nextDouble() * 0.01,
        color: [
          const Color(0xFF2DBD6E),
          const Color(0xFFF5A623),
          const Color(0xFF7B61FF),
          Colors.white,
          const Color(0xFFFF6B6B),
          const Color(0xFF4FC3F7),
        ][_rng.nextInt(6)],
        size: 4 + _rng.nextDouble() * 6,
        rotation: _rng.nextDouble() * 2 * pi,
        rotSpeed: (_rng.nextDouble() - 0.5) * 0.15,
        shape: _rng.nextInt(3),
      ));
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Particle {
  double x, y, vx, vy, size, rotation, rotSpeed;
  Color color;
  int shape;
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotSpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = progress;
      final px = (p.x + p.vx * t * 80) * size.width;
      final py = (p.y + p.vy * t * 80 + 0.5 * 0.00015 * t * t * 80 * 80) *
          size.height;
      final opacity = (1 - t).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withOpacity(opacity);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + p.rotSpeed * t * 60);

      switch (p.shape) {
        case 0: // rectangle
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset.zero, width: p.size, height: p.size * 0.5),
              paint);
          break;
        case 1: // circle
          canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
          break;
        case 2: // triangle
          final path = Path()
            ..moveTo(0, -p.size * 0.5)
            ..lineTo(p.size * 0.4, p.size * 0.4)
            ..lineTo(-p.size * 0.4, p.size * 0.4)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}