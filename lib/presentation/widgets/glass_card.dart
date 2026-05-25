import 'package:flutter/material.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = Spacing.cardPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              isDark
                  ? AppColors.white.withValues(alpha: .08)
                  : const Color(0xFFE7ECF3),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: .05),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
        ],
      ),
      child: child,
    );
  }
}
