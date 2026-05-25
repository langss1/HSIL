import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_logo_mark.dart';
import '../widgets/fade_slide.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackdrop(
        child: SafeArea(
          child: Padding(
            padding: Spacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const FadeSlide(child: AppLogoMark(size: 86)),
                const SizedBox(height: Spacing.lg),
                FadeSlide(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                FadeSlide(
                  delay: const Duration(milliseconds: 180),
                  child: Text(
                    AppConstants.appTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.safetyOrange,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
