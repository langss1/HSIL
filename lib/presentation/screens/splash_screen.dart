import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_logo_mark.dart';
import '../widgets/dot_loader.dart';
import '../widgets/fade_slide.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: Spacing.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo with pulse glow ring
                  FadeSlide(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring pulse
                            Transform.scale(
                              scale: _pulseAnimation.value * 1.18,
                              child: Container(
                                width: 116,
                                height: 116,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.safetyOrange.withValues(
                                        alpha: 0.15 *
                                            (1 -
                                                (_pulseAnimation.value - 0.88) /
                                                    0.12),
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Logo
                            Transform.scale(
                              scale: 0.92 + (_pulseAnimation.value - 0.88) * 0.5,
                              child: const AppLogoMark(size: 96),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),

                  // App name with solid high-contrast text
                  FadeSlide(
                    delay: const Duration(milliseconds: 120),
                    child: Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.white
                                    : AppColors.deepNavy,
                              ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Tagline in crisp safety orange
                  FadeSlide(
                    delay: const Duration(milliseconds: 240),
                    child: Text(
                      AppConstants.appTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.safetyOrange,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),

                  // Dot Loader
                  FadeSlide(
                    delay: const Duration(milliseconds: 360),
                    child: const DotLoader(),
                  ),
                  const SizedBox(height: Spacing.lg),

                  // Version badge
                  FadeSlide(
                    delay: const Duration(milliseconds: 480),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.safetyOrange.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.safetyOrange.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.factory_rounded,
                            size: 12,
                            color: AppColors.safetyOrange.withValues(alpha: 0.80),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppConstants.officeName,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.safetyOrange
                                      .withValues(alpha: 0.85),
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
