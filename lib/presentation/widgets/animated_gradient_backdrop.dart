import 'package:flutter/material.dart';

import '../../core/themes/color_palette.dart';

/// A calm app surface. The old class name is kept so existing screens stay
/// simple, but the visual treatment is now intentionally minimal.
class AnimatedGradientBackdrop extends StatelessWidget {
  const AnimatedGradientBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.deepNavy : AppColors.bgLight,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: _SoftAccent(
              color: AppColors.safetyOrange.withValues(alpha: .08),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _SoftAccent extends StatelessWidget {
  const _SoftAccent({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
