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
          borderRadius: BorderRadius.circular(size * .24),
          color: AppColors.deepNavy,
        ),
        child: const Icon(
          Icons.verified_user_rounded,
          color: AppColors.safetyOrange,
          size: 34,
        ),
      ),
    );
  }
}
