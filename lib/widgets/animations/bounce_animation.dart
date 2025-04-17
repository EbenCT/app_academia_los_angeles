import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Widget para crear animaciones de rebote
class BounceAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final bool autoPlay;
  final bool infinite;
  final double from;
  final double to;

  const BounceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.autoPlay = true,
    this.infinite = false,
    this.from = 0.0,
    this.to = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    var effects = <Effect>[
      ScaleEffect(
        delay: delay,
        duration: duration,
        curve: Curves.elasticOut,
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
      ),
    ];

    if (infinite) {
      return Animate(
        effects: effects,
        onComplete: (controller) => controller.repeat(reverse: true),
        child: child,
      );
    } else {
      return Animate(
        effects: effects,
        autoPlay: autoPlay,
        child: child,
      );
    }
  }
}