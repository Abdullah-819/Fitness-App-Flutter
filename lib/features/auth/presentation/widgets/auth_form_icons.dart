import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Pixel-perfect vector icon for Email envelope matching design 16_Light_sign in blank form.png.
class AuthMailIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AuthMailIcon({
    super.key,
    this.size = 22,
    this.color = AppColors.textLight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AuthMailPainter(color: color),
      ),
    );
  }
}

class _AuthMailPainter extends CustomPainter {
  final Color color;

  _AuthMailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = math.max(1.6, w * 0.08);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final padding = strokeWidth / 2 + 1;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        padding,
        h * 0.18,
        w - padding * 2,
        h * 0.64,
      ),
      const Radius.circular(5),
    );

    // Envelope outline
    canvas.drawRRect(bodyRect, paint);

    // Envelope flap fold
    final flapPath = Path()
      ..moveTo(padding + 1, h * 0.22)
      ..lineTo(w * 0.5, h * 0.56)
      ..lineTo(w - padding - 1, h * 0.22);

    canvas.drawPath(flapPath, paint);
  }

  @override
  bool shouldRepaint(covariant _AuthMailPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Pixel-perfect vector icon for Password lock matching design 16_Light_sign in blank form.png.
class AuthLockIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AuthLockIcon({
    super.key,
    this.size = 22,
    this.color = AppColors.textLight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AuthLockPainter(color: color),
      ),
    );
  }
}

class _AuthLockPainter extends CustomPainter {
  final Color color;

  _AuthLockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = math.max(1.6, w * 0.08);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Shackle (upper arch)
    final shackleRect = Rect.fromLTWH(
      w * 0.28,
      h * 0.12,
      w * 0.44,
      h * 0.46,
    );
    canvas.drawArc(shackleRect, math.pi, math.pi, false, strokePaint);

    // Shackle vertical legs
    canvas.drawLine(
      Offset(w * 0.28, h * 0.35),
      Offset(w * 0.28, h * 0.48),
      strokePaint,
    );
    canvas.drawLine(
      Offset(w * 0.72, h * 0.35),
      Offset(w * 0.72, h * 0.48),
      strokePaint,
    );

    // Lock body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w * 0.18,
        h * 0.44,
        w * 0.64,
        h * 0.46,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(bodyRect, strokePaint);

    // Keyhole dot
    canvas.drawCircle(Offset(w * 0.5, h * 0.64), strokeWidth * 0.9, fillPaint);
    canvas.drawLine(
      Offset(w * 0.5, h * 0.64),
      Offset(w * 0.5, h * 0.73),
      strokePaint..strokeWidth = strokeWidth * 0.9,
    );
  }

  @override
  bool shouldRepaint(covariant _AuthLockPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Pixel-perfect vector icon for Show/Hide Password eye toggle matching design 16_Light_sign in blank form.png.
class AuthEyeIcon extends StatelessWidget {
  final bool isObscured;
  final double size;
  final Color color;

  const AuthEyeIcon({
    super.key,
    required this.isObscured,
    this.size = 22,
    this.color = AppColors.textLight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AuthEyePainter(
          isObscured: isObscured,
          color: color,
        ),
      ),
    );
  }
}

class _AuthEyePainter extends CustomPainter {
  final bool isObscured;
  final Color color;

  _AuthEyePainter({required this.isObscured, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = math.max(1.6, w * 0.08);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Eye outline curve (upper & lower lid)
    final eyePath = Path()
      ..moveTo(w * 0.12, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.18, w * 0.88, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.82, w * 0.12, h * 0.5);

    canvas.drawPath(eyePath, paint);

    // Center pupil
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.15, fillPaint);

    // Diagonal slash line when obscured
    if (isObscured) {
      canvas.drawLine(
        Offset(w * 0.84, h * 0.18),
        Offset(w * 0.16, h * 0.82),
        paint..strokeWidth = strokeWidth * 1.1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuthEyePainter oldDelegate) =>
      oldDelegate.isObscured != isObscured || oldDelegate.color != color;
}
