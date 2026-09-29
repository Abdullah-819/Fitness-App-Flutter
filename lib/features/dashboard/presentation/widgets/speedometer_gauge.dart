import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Speedometer-style circular arc step gauge matching the Figma Dashboard design.
///
/// Features:
/// - Custom painted 270-degree rounded gauge track with inner radial tick marks
/// - Dynamic progress fill with smooth animation
/// - Bold step counter typography with goal indicator
/// - Interactive start/pause action button positioned at the bottom opening
class SpeedometerGauge extends StatelessWidget {
  final int currentSteps;
  final int stepGoal;
  final bool isActive;
  final VoidCallback onToggle;

  const SpeedometerGauge({
    super.key,
    required this.currentSteps,
    required this.stepGoal,
    required this.isActive,
    required this.onToggle,
  });

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = stepGoal > 0 ? (currentSteps / stepGoal).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 270,
          height: 270,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom arc gauge painter
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, animatedProgress, child) {
                  return CustomPaint(
                    size: const Size(270, 270),
                    painter: _SpeedometerPainter(
                      progress: animatedProgress,
                      primaryColor: AppColors.primaryPurple,
                      trackColor: const Color(0xFFEBECEF),
                      tickColor: const Color(0xFFD4D6DD),
                    ),
                  );
                },
              ),

              // Central text information
              Positioned(
                top: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatNumber(currentSteps),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/${_formatNumber(stepGoal)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Center bottom Play/Pause button
              Positioned(
                bottom: 12,
                child: GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.white : AppColors.primaryPurple,
                      border: isActive
                          ? Border.all(color: AppColors.primaryPurple, width: 2.5)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(
                            alpha: isActive ? 0.15 : 0.35,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isActive
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isActive ? AppColors.primaryPurple : Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;
  final Color tickColor;

  _SpeedometerPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 8);
    const radius = 108.0;
    const strokeWidth = 24.0;

    // 270 degree arc from 135 deg to 405 deg
    const startAngle = 135 * (math.pi / 180);
    const totalSweep = 270 * (math.pi / 180);

    // 1. Background inactive track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    // 2. Inner Radial Tick Marks
    final tickPaint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const tickCount = 20;
    const tickInnerRadius = radius - 24.0;
    const tickOuterRadius = radius - 16.0;

    for (int i = 0; i <= tickCount; i++) {
      final angle = startAngle + (i / tickCount) * totalSweep;
      final start = Offset(
        center.dx + tickInnerRadius * math.cos(angle),
        center.dy + tickInnerRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + tickOuterRadius * math.cos(angle),
        center.dy + tickOuterRadius * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // 3. Active progress track
    if (progress > 0.0) {
      final activeSweep = totalSweep * progress.clamp(0.001, 1.0);
      final activePaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.trackColor != trackColor;
  }
}
