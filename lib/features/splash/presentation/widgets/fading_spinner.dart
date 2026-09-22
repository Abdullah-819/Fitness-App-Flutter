import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Smooth rotating circular loading spinner with a fading sweep gradient arc.
class FadingSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  const FadingSpinner({
    super.key,
    this.size = 58,
    this.strokeWidth = 7.0,
    this.color = Colors.white,
  });

  @override
  State<FadingSpinner> createState() => _FadingSpinnerState();
}

class _FadingSpinnerState extends State<FadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
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
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _FadingArcPainter(
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        );
      },
    );
  }
}

class _FadingArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _FadingArcPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    const arcAngle = 1.75 * math.pi;

    final gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: arcAngle,
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.25),
        color.withValues(alpha: 0.65),
        color,
      ],
      stops: const [0.0, 0.35, 0.75, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0.0, arcAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _FadingArcPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
