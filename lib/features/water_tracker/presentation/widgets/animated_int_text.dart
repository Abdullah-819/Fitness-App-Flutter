import 'package:flutter/material.dart';

/// Counts smoothly from the previous value to [value] whenever it changes
/// (and from 0 the first time it appears). [builder] draws the number.
class AnimatedIntText extends StatelessWidget {
  final int value;
  final Widget Function(BuildContext context, int current) builder;
  final Duration duration;

  const AnimatedIntText({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: reduceMotion ? Duration.zero : duration,
      curve: Curves.easeOutCubic,
      builder: (context, current, _) => builder(context, current),
    );
  }
}

/// Formats 1750 as "1,750".
String formatMl(int value) {
  if (value >= 1000) {
    final whole = value ~/ 1000;
    final rem = (value % 1000).toString().padLeft(3, '0');
    return '$whole,$rem';
  }
  return value.toString();
}
