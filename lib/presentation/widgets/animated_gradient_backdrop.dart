import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/themes/color_palette.dart';

/// Premium animated gradient backdrop — Deep Navy mesh with animated glow orbs
class AnimatedGradientBackdrop extends StatefulWidget {
  const AnimatedGradientBackdrop({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackdrop> createState() =>
      _AnimatedGradientBackdropState();
}

class _AnimatedGradientBackdropState extends State<AnimatedGradientBackdrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFF071224),
                      Color(0xFF0B1D3A),
                      Color(0xFF0E2445),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFFFAFBFC),
                      Color(0xFFFFFFFF),
                      Color(0xFFF1F3F7),
                    ],
                  ),
          ),
          child: Stack(
            children: [
              // Glow orb 1 — top right (orange accent)
              Positioned(
                top: -80 + (math.sin(t * math.pi * 2) * 30),
                right: -60 + (math.cos(t * math.pi * 2) * 20),
                child: _GlowOrb(
                  size: 280,
                  color: AppColors.safetyOrange.withValues(
                    alpha: isDark ? 0.06 : 0.025,
                  ),
                ),
              ),
              // Glow orb 2 — bottom left (deep navy accent)
              Positioned(
                bottom: -100 + (math.cos(t * math.pi * 2) * 25),
                left: -80 + (math.sin(t * math.pi * 2) * 20),
                child: _GlowOrb(
                  size: 320,
                  color: AppColors.deepNavy.withValues(
                    alpha: isDark ? 0.05 : 0.015,
                  ),
                ),
              ),
              // Glow orb 3 — center subtle
              Positioned(
                top: MediaQuery.sizeOf(context).height * 0.35 +
                    (math.sin(t * math.pi) * 40),
                right: MediaQuery.sizeOf(context).width * 0.15,
                child: _GlowOrb(
                  size: 180,
                  color: AppColors.safetyOrange.withValues(
                    alpha: isDark ? 0.04 : 0.015,
                  ),
                ),
              ),
              // Content
              Positioned.fill(child: widget.child),
            ],
          ),
        );
      },
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
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
