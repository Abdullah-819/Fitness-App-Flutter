import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

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
    final p = AppPalette.of(context);
    final progress = stepGoal > 0 ? (currentSteps / stepGoal).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom arc gauge painter
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, animatedProgress, child) {
                  return CustomPaint(
                    size: const Size(300, 300),
                    painter: _SpeedometerPainter(
                      progress: animatedProgress,
                      primaryColor: AppColors.primaryPurple,
                      trackColor: p.ringTrack,
                      tickColor: p.ringTick,
                      isDark: p.isDark,
                    ),
                  );
                },
              ),

              // Central text information
              Positioned(
                top: 92,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: p.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(end: currentSteps),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Text(
                        _formatNumber(value),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: p.textPrimary,
                          letterSpacing: -1.2,
                          height: 1.1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/$stepGoal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: p.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Center bottom Play/Pause button
              Positioned(
                top: 212,
                child: GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? p.card : AppColors.primaryPurple,
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
                            ? LucideIcons.pause
                            : LucideIcons.play,
                        color: isActive ? AppColors.primaryPurple : Colors.white,
                        size: 26,
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
  final bool isDark;

  _SpeedometerPainter({
    required this.isDark,
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 120.0;
    const strokeWidth = 30.0;

    // 270 degree arc from 135 deg to 405 deg
    const startAngle = 135 * (math.pi / 180);
    const totalSweep = 270 * (math.pi / 180);

    final trackRect = Rect.fromCircle(center: center, radius: radius);

    void arc(Rect rect, Paint paint, [double sweep = totalSweep]) =>
        canvas.drawArc(rect, startAngle, sweep, false, paint);

    Paint stroke(Color color, {double? width, double blur = 0}) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width ?? strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null;

    // 1. Embossed track: dark drop shadow (bottom-right), white highlight
    // (top-left), then the soft grey body with a gentle sweep gradient.
    arc(trackRect.shift(const Offset(4, 7)),
        stroke(Colors.black.withValues(alpha: isDark ? 0.45 : 0.16), blur: 8));
    arc(trackRect.shift(const Offset(-3, -4)),
        stroke(isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            blur: 5));
    arc(
      trackRect,
      stroke(trackColor)
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: totalSweep,
          colors: isDark
              ? const [Color(0xFF2F313D), Color(0xFF2B2D38), Color(0xFF262833)]
              : const [Color(0xFFF7F7F7), Color(0xFFECECEC), Color(0xFFE4E4E4)],
          transform: const GradientRotation(startAngle),
        ).createShader(trackRect),
    );
    // Inner rim light for the rounded "tube" look
    arc(trackRect, stroke(Colors.white.withValues(alpha: isDark ? 0.04 : 0.6),
        width: strokeWidth - 18, blur: 3));

    // 2. Inner Radial Tick Marks
    final tickPaint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const tickCount = 10;
    const tickInnerRadius = radius - 40.0;
    const tickOuterRadius = radius - 32.0;

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
      arc(trackRect.shift(const Offset(0, 5)),
          stroke(primaryColor.withValues(alpha: 0.35), blur: 7), activeSweep);
      arc(trackRect, stroke(primaryColor), activeSweep);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.trackColor != trackColor;
  }
}
