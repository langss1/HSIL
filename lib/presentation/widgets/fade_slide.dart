import 'package:flutter/material.dart';

class FadeSlide extends StatelessWidget {
  const FadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, .08),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // We want opacity to stay 0 during the delay phase.
        // The total animation is over (500 + delay) ms.
        // value goes from 0.0 to 1.0 over the total duration.
        // The delay phase is the fraction: delay / (500 + delay)
        final totalMs = 500.0 + delay.inMilliseconds;
        final delayFraction = delay.inMilliseconds / totalMs;
        
        // Progress of the actual fade/slide part (0.0 to 1.0)
        double progress = 0.0;
        if (value > delayFraction) {
          progress = (value - delayFraction) / (1.0 - delayFraction);
        }

        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: offset * (1.0 - progress) * 80,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
