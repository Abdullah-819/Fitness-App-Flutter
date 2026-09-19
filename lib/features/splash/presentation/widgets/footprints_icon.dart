import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Minimalist, flat vector rendering of two overlapping shoeprints / footprints.
class FootprintsIcon extends StatelessWidget {
  final double size;
  final Color color;

  const FootprintsIcon({super.key, this.size = 110, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: _FootprintsPainter(color: color),
    );
  }
}

class _FootprintsPainter extends CustomPainter {
  final Color color;

  _FootprintsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Left footprint (stepping back, angled ~ -18 deg)
    canvas.save();
    canvas.translate(w * 0.36, h * 0.52);
    canvas.rotate(-18 * math.pi / 180);
    _drawSingleShoeprint(canvas, paint, w * 0.38, h * 0.56);
    canvas.restore();

    // Right footprint (stepping forward, angled ~ +4 deg)
    canvas.save();
    canvas.translate(w * 0.64, h * 0.42);
    canvas.rotate(4 * math.pi / 180);
    _drawSingleShoeprint(canvas, paint, w * 0.38, h * 0.56);
    canvas.restore();
  }

  void _drawSingleShoeprint(Canvas canvas, Paint paint, double pw, double ph) {
    // Upper sole
    final soleRect = Rect.fromCenter(
      center: Offset(0, -ph * 0.18),
      width: pw,
      height: ph * 0.54,
    );
    final soleRRect = RRect.fromRectAndCorners(
      soleRect,
      topLeft: Radius.circular(pw * 0.48),
      topRight: Radius.circular(pw * 0.48),
      bottomLeft: Radius.circular(pw * 0.32),
      bottomRight: Radius.circular(pw * 0.32),
    );
    canvas.drawRRect(soleRRect, paint);

    // Heel
    final heelRect = Rect.fromCenter(
      center: Offset(0, ph * 0.28),
      width: pw * 0.82,
      height: ph * 0.30,
    );
    final heelRRect = RRect.fromRectAndCorners(
      heelRect,
      topLeft: Radius.circular(pw * 0.26),
      topRight: Radius.circular(pw * 0.26),
      bottomLeft: Radius.circular(pw * 0.42),
      bottomRight: Radius.circular(pw * 0.42),
    );
    canvas.drawRRect(heelRRect, paint);
  }

  @override
  bool shouldRepaint(covariant _FootprintsPainter oldDelegate) =>
      oldDelegate.color != color;
}
