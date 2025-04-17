import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Widget para crear animaciones de desvanecimiento
class FadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;
  final Offset? slideOffset;

  const FadeAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
    this.begin = 0.0,
    this.end = 1.0,
    this.slideOffset,
  });

  @override
  Widget build(BuildContext context) {
    var effects = <Effect>[];
    
    // Añadir efecto de desvanecimiento
    effects.add(FadeEffect(
      delay: delay,
      duration: duration,
      curve: curve,
      begin: begin,
      end: end,
    ));
    
    // Añadir efecto de deslizamiento si se proporciona
    if (slideOffset != null) {
      effects.add(SlideEffect(
        delay: delay,
        duration: duration,
        curve: curve,
        begin: slideOffset!,
        end: Offset.zero,
      ));
    }
    
    return Animate(
      effects: effects,
      child: child,
    );
  }
}