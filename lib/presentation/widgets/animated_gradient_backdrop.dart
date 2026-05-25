import 'package:flutter/material.dart';

import '../../core/themes/color_palette.dart';

class AnimatedGradientBackdrop extends StatefulWidget {
  const AnimatedGradientBackdrop({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackdrop> createState() =>
      _AnimatedGradientBackdropState();
}

class _AnimatedGradientBackdropState extends State<AnimatedGradientBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + value * .4, -1),
              end: Alignment(1, 1 - value * .3),
              colors: const [
                AppColors.bgDarker,
                AppColors.deepNavy,
                AppColors.bgCard,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -120 + value * 28,
                right: -90,
                child: _GlowOrb(
                  size: 260,
                  color: AppColors.safetyOrange.withValues(alpha: .20),
                ),
              ),
              Positioned(
                bottom: -110,
                left: -80 + value * 30,
                child: _GlowOrb(
                  size: 240,
                  color: AppColors.info.withValues(alpha: .16),
                ),
              ),
              Positioned.fill(child: child!),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
