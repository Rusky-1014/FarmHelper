import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double borderWidth;
  final BorderRadius borderRadius;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    required this.colors,
    this.borderWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
  });

  @override
  State<AnimatedGradientBorder> createState() =>
      _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            colors: widget.colors,
            angle: _controller.value * 2 * pi,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
          ),
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.all(widget.borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
                widget.borderRadius.topLeft.x - widget.borderWidth),
            topRight: Radius.circular(
                widget.borderRadius.topRight.x - widget.borderWidth),
            bottomLeft: Radius.circular(
                widget.borderRadius.bottomLeft.x - widget.borderWidth),
            bottomRight: Radius.circular(
                widget.borderRadius.bottomRight.x - widget.borderWidth),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final List<Color> colors;
  final double angle;
  final double borderWidth;
  final BorderRadius borderRadius;

  _GradientBorderPainter({
    required this.colors,
    required this.angle,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);

    final gradient = SweepGradient(
      startAngle: angle,
      endAngle: angle + 2 * pi,
      colors: [...colors, colors.first],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) =>
      old.angle != angle;
}