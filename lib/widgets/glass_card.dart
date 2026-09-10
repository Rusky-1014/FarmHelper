import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? tintColor;
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding,
    this.borderRadius,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? (tintColor ?? Colors.white).withOpacity(0.06)
                : (tintColor ?? Colors.white).withOpacity(0.72),
            borderRadius: br,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.white.withOpacity(0.9),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}