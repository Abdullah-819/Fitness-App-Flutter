import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Authentic Google 4-color 'G' logo drawn using vector paths.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final strokeWidth = w * 0.22;
    final radius = (w - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Red (Top arc: 220 deg to 315 deg approx -> -140 to -45 deg)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -math.pi * 0.82, math.pi * 0.57, false, paint);

    // Blue (Right arc + horizontal bar)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.5, false, paint);

    // Green (Bottom arc)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.57, false, paint);

    // Yellow (Left arc)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, math.pi * 0.82, math.pi * 0.36, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - 1, center.dy - strokeWidth / 2, radius + strokeWidth / 2 + 1, strokeWidth),
      Radius.zero,
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Apple logo widget.
class AppleLogo extends StatelessWidget {
  final double size;
  final Color color;

  const AppleLogo({super.key, this.size = 24, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.apple,
      size: size,
      color: color,
    );
  }
}

/// Official Facebook circular brand icon with white 'f'.
class FacebookLogo extends StatelessWidget {
  final double size;

  const FacebookLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.76,
            fontWeight: FontWeight.w900,
            fontFamily: 'sans-serif',
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
