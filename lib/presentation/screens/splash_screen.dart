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
                  // Elegant floating 3D logo
                  FadeSlide(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1400),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              // Konversi _pulseAnimation (0.88 -> 1.0) menjadi nilai float (-8.0 -> 8.0)
                              final floatOffset = ((_pulseAnimation.value - 0.88) / 0.12 * 16) - 8;
                              
                              return Transform.translate(
                                offset: Offset(0, floatOffset),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Elegant soft glow
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.safetyOrange.withValues(
                                              alpha: 0.2 + ((_pulseAnimation.value - 0.88) / 0.12) * 0.1,
                                            ),
                                            blurRadius: 50,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Logo
                                    const AppLogoMark(size: 220),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: Spacing.xl),

                  // App name with premium typography
                  FadeSlide(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Absen!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            fontSize: 48,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.white
                                : AppColors.deepNavy,
                            shadows: [
                              Shadow(
                                color: AppColors.deepNavy.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Tagline with professional styling
                  FadeSlide(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      AppConstants.appTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.safetyOrange,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            fontSize: 16,
                          ),
                    ),
                  ),
                  
                  // Spacing to loader
                  const SizedBox(height: 80),

                  // Minimalist loading indicator
                  FadeSlide(
                    delay: const Duration(milliseconds: 600),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.safetyOrange.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 3.5,
                        color: AppColors.safetyOrange,
                        strokeCap: StrokeCap.round,
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
