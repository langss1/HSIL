import 'package:flutter/material.dart';

import '../../core/themes/color_palette.dart';

class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 68});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'HSIL Attendance logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.safetyOrange, Color(0xFFFFB199)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.safetyOrange.withValues(alpha: .28),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: const Icon(
          Icons.verified_user_rounded,
          color: AppColors.white,
          size: 34,
        ),
      ),
    );
  }
}
