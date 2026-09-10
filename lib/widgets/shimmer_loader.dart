import 'package:flutter/material.dart';

class ShimmerLoader extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;
  final Widget child;

  const ShimmerLoader({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.child,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_animation.value - 1) / 3,
                (_animation.value) / 3,
                (_animation.value + 1) / 3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// ── Shimmer text specifically for analyzing state ────────────────────────────

class AnalyzingShimmerText extends StatelessWidget {
  final String text;
  final Color accentColor;
  const AnalyzingShimmerText(
      {super.key, required this.text, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      baseColor: accentColor.withOpacity(0.6),
      highlightColor: Colors.white,
      child: Text(
        text,
        style: TextStyle(
          color: accentColor,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}