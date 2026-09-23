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
    final scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Red (Top arc)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(24.0, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.9, 2.38, 30.47, 0.0, 24.0, 0.0)
      ..cubicTo(14.62, 0.0, 6.51, 5.38, 2.56, 13.22)
      ..lineTo(10.54, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24.0, 9.5)
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow (Left arc)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(10.53, 28.59)
      ..cubicTo(10.05, 27.14, 9.77, 25.6, 9.77, 24.0)
      ..cubicTo(9.77, 22.4, 10.05, 20.86, 10.53, 19.41)
      ..lineTo(2.56, 13.22)
      ..cubicTo(0.92, 16.46, 0.0, 20.12, 0.0, 24.0)
      ..cubicTo(0.0, 27.88, 0.92, 31.54, 2.56, 34.78)
      ..lineTo(10.53, 28.59)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green (Bottom arc)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(24.0, 48.0)
      ..cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.19)
      ..lineTo(32.16, 36.19)
      ..cubicTo(30.01, 37.64, 27.24, 38.5, 24.0, 38.5)
      ..cubicTo(17.74, 38.5, 12.43, 34.28, 10.53, 28.59)
      ..lineTo(2.56, 34.78)
      ..cubicTo(6.51, 42.62, 14.62, 48.0, 24.0, 48.0)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Blue (Right arc + horizontal bar)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.6, 20.0)
      ..lineTo(24.0, 20.0)
      ..lineTo(24.0, 29.02)
      ..lineTo(36.94, 29.02)
      ..cubicTo(36.36, 31.98, 34.68, 34.5, 32.16, 36.2)
      ..lineTo(39.89, 42.2)
      ..cubicTo(44.4, 38.02, 46.98, 31.84, 46.98, 24.55)
      ..close();
    canvas.drawPath(bluePath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Apple logo widget with equal 24x24 box dimensions.
class AppleLogo extends StatelessWidget {
  final double size;
  final Color color;

  const AppleLogo({super.key, this.size = 24, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(
          Icons.apple,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

/// Official Facebook circular brand icon with white 'f'.
class FacebookLogo extends StatelessWidget {
  final double size;

  const FacebookLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.72,
              height: size * 0.72,
              color: Colors.white,
            ),
            Icon(
              Icons.facebook,
              size: size,
              color: const Color(0xFF1877F2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Official Twitter bird logo widget matching the onboarding design.
class TwitterLogo extends StatelessWidget {
  final double size;
  final Color color;

  const TwitterLogo({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF1DA1F2),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TwitterLogoPainter(color: color),
      ),
    );
  }
}

class _TwitterLogoPainter extends CustomPainter {
  final Color color;

  const _TwitterLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(24.0, 4.555)
      ..cubicTo(23.117, 4.949, 22.167, 5.215, 21.171, 5.334)
      ..cubicTo(22.188, 4.724, 22.969, 3.759, 23.337, 2.607)
      ..cubicTo(22.387, 3.17, 21.334, 3.58, 20.213, 3.8)
      ..cubicTo(19.316, 2.846, 18.039, 2.25, 16.627, 2.25)
      ..cubicTo(13.914, 2.25, 11.714, 4.45, 11.714, 7.163)
      ..cubicTo(11.714, 7.549, 11.757, 7.924, 11.841, 8.284)
      ..cubicTo(7.759, 8.079, 4.116, 6.111, 1.678, 3.118)
      ..cubicTo(1.253, 3.847, 1.01, 4.695, 1.01, 5.599)
      ..cubicTo(1.01, 7.303, 1.877, 8.807, 3.197, 9.689)
      ..cubicTo(2.392, 9.664, 1.634, 9.444, 0.971, 9.076)
      ..cubicTo(0.97, 9.096, 0.97, 9.117, 0.97, 9.138)
      ..cubicTo(0.97, 11.517, 2.663, 13.502, 4.909, 13.953)
      ..cubicTo(4.497, 14.065, 4.063, 14.125, 3.615, 14.125)
      ..cubicTo(3.3, 14.125, 2.993, 14.094, 2.695, 14.037)
      ..cubicTo(3.32, 15.986, 5.132, 17.406, 7.28, 17.446)
      ..cubicTo(5.599, 18.763, 3.481, 19.549, 1.18, 19.549)
      ..cubicTo(0.784, 19.549, 0.393, 19.526, 0.009, 19.48)
      ..cubicTo(2.179, 20.871, 4.757, 21.684, 7.527, 21.684)
      ..cubicTo(16.549, 21.684, 21.482, 14.212, 21.482, 7.728)
      ..cubicTo(21.482, 7.515, 21.477, 7.303, 21.468, 7.092)
      ..cubicTo(22.426, 6.4, 23.259, 5.538, 23.909, 4.555)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
