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
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 520 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayedValue = (value - delay.inMilliseconds / 1000).clamp(0, 1);
        return Opacity(
          opacity: delayedValue.toDouble(),
          child: Transform.translate(
            offset: offset * (1 - delayedValue.toDouble()) * 80,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
