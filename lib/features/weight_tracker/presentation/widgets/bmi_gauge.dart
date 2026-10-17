import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/weight_models.dart';

/// Semicircle BMI gauge with five coloured bands and an animated needle.
class BmiGauge extends StatelessWidget {
  final double bmi;

  const BmiGauge({super.key, required this.bmi});

  /// Needle angle as 0..1 across the arc. Each band owns an equal fifth,
  /// like the design, with the BMI interpolated inside its band.
  static double fractionFor(double bmi) {
    const lowest = 10.0; // left edge of the Underweight band
    const highest = 50.0; // right edge of the Morbidly Obese band
    final bands = bmiCategories.length;
    final clamped = bmi.clamp(lowest, highest).toDouble();
    for (var i = 0; i < bands; i++) {
      final c = bmiCategories[i];
      final lo = i == 0 ? lowest : c.min;
      final hi = i == bands - 1 ? highest : c.max;
      if (clamped < hi || i == bands - 1) {
        return (i + (clamped - lo) / (hi - lo)) / bands;
      }
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return AspectRatio(
      aspectRatio: 2.0,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: fractionFor(bmi)),
        duration: reduce ? Duration.zero : const Duration(milliseconds: 900),
        curve: Curves.easeOutBack,
        builder: (context, fraction, _) =>
            CustomPaint(painter: _GaugePainter(fraction)),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;

  _GaugePainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final outer = size.width / 2;
    final inner = outer * 0.62;
    final n = bmiCategories.length;
    final sweep = math.pi / n;
    final rect = Rect.fromCircle(center: center, radius: outer);

    for (var i = 0; i < n; i++) {
      final start = math.pi + i * sweep;
      final path = Path()
        ..arcTo(rect, start, sweep, true)
        ..arcTo(
          Rect.fromCircle(center: center, radius: inner),
          start + sweep,
          -sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, Paint()..color = bmiCategories[i].color);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white,
      );

      _paintLabel(canvas, center, (outer + inner) / 2, start + sweep / 2, i);
    }

    _paintNeedle(canvas, center, inner);
  }

  void _paintLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    int i,
  ) {
    final c = bmiCategories[i];
    final dark = c.color == const Color(0xFFFFEB3B);
    final color = dark ? Colors.black87 : Colors.white;
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${c.label}\n',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          TextSpan(
            text: c.range,
            style: TextStyle(color: color, fontSize: 8.5, height: 1.15),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 70);

    canvas.save();
    canvas.translate(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.rotate(angle + math.pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  void _paintNeedle(Canvas canvas, Offset center, double inner) {
    final angle = math.pi + fraction * math.pi;
    final length = inner * 0.95;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final needle = Path()
      ..moveTo(length, 0)
      ..lineTo(0, -inner * 0.2)
      ..lineTo(0, inner * 0.2)
      ..close();
    canvas.drawPath(needle, Paint()..color = const Color(0xFF3C3C3C));
    canvas.restore();

    canvas.drawCircle(
      center,
      inner * 0.2,
      Paint()..color = const Color(0xFF3C3C3C),
    );
    canvas.drawCircle(center, inner * 0.11, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.fraction != fraction;
}
