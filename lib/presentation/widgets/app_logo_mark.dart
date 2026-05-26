import 'package:flutter/material.dart';
import '../../core/themes/color_palette.dart';

/// App logo — uses Absen.png asset in a clean, minimalist rounded rectangle layout
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'HSIL Attendance logo',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: size,
            height: size,
            child: Image.asset(
              'assets/Absen.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
