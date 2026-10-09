import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// "+250 ml" chip that pops out, floats up and fades whenever water is added.
/// Change [triggerId] (any new value) to replay it; 0 shows nothing.
class FloatingAmountLabel extends StatelessWidget {
  final int amountMl;
  final int triggerId;

  const FloatingAmountLabel({
    super.key,
    required this.amountMl,
    required this.triggerId,
  });

  @override
  Widget build(BuildContext context) {
    if (triggerId == 0) return const SizedBox.shrink();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(triggerId),
        tween: Tween<double>(begin: 0, end: 1),
        duration: reduceMotion
            ? const Duration(milliseconds: 1)
            : const Duration(milliseconds: 1500),
        builder: (context, t, child) {
          final rise = Curves.easeOutCubic.transform(t) * 70;
          // Quick pop-in, hold, then fade out.
          final opacity = t < 0.15
              ? t / 0.15
              : (t > 0.7 ? (1 - (t - 0.7) / 0.3).clamp(0.0, 1.0) : 1.0);
          final scale = 0.6 + 0.4 * Curves.easeOutBack.transform((t / 0.25).clamp(0.0, 1.0));
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, -rise),
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '+$amountMl ml',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
