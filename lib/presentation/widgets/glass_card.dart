import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';

/// Premium glassmorphism card — BackdropFilter blur + gradient border
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = Spacing.cardPadding,
    this.onTap,
    this.borderRadius = 20,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = glowColor ?? AppColors.safetyOrange.withValues(alpha: 0.0);

    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A2E47).withValues(alpha: 0.85),
                      const Color(0xFF152538).withValues(alpha: 0.90),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.98),
                    ],
                  ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              if (!isDark)
                BoxShadow(
                  color: AppColors.deepNavy.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              if (glowColor != null)
                BoxShadow(
                  color: glow,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
