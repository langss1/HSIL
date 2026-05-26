import 'package:flutter/material.dart';
import '../../core/themes/color_palette.dart';

/// App logo — uses Absen.png asset with glow ring & gradient container
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 68});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'HSIL Attendance logo',
      child: Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFF253D5C),
              Color(0xFF0B1D3A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.safetyOrange.withValues(alpha: 0.35),
              blurRadius: size * 0.55,
              spreadRadius: size * 0.04,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: size * 0.30,
              offset: Offset(0, size * 0.12),
            ),
          ],
          border: Border.all(
            color: AppColors.safetyOrange.withValues(alpha: 0.30),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(size * 0.08),
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
