import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A fluid water droplet indicator featuring an animated liquid wave
/// inside a teardrop silhouette.
class WaterDropletIndicator extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double width;
  final double height;
  final bool animated;

  const WaterDropletIndicator({
    super.key,
    required this.progress,
    this.width = 170,
    this.height = 210,
    this.animated = true,
  });

  @override
  State<WaterDropletIndicator> createState() => _WaterDropletIndicatorState();
}

class _WaterDropletIndicatorState extends State<WaterDropletIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    if (widget.animated) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WaterDropletIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!widget.animated && _waveController.isAnimating) {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _WaterDropletPainter(
            progress: widget.progress.clamp(0.0, 1.0),
            wavePhase: _waveController.value * 2 * math.pi,
          ),
        );
      },
    );
  }
}

class _WaterDropletPainter extends CustomPainter {
  final double progress;
  final double wavePhase;

  _WaterDropletPainter({
    required this.progress,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Droplet shape path
    final dropletPath = _createDropletPath(size);

    // 1. Draw outer subtle glow / ambient droplet shadow
    final outerPath = _createDropletPath(Size(w * 1.14, h * 1.14));
    final outerOffset = Offset(-w * 0.07, -h * 0.07);
    canvas.save();
    canvas.translate(outerOffset.dx, outerOffset.dy);
    final outerPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(outerPath, outerPaint);
    canvas.restore();

    // 2. Draw inner background droplet (unfilled area)
    final bgPaint = Paint()
      ..color = const Color(0xFFEBF3FE)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dropletPath, bgPaint);

    // Subtle droplet inner border
    final borderPaint = Paint()
      ..color = const Color(0xFFD6E4F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(dropletPath, borderPaint);

    // 3. Clip everything inside the droplet
    canvas.save();
    canvas.clipPath(dropletPath);

    // If progress is greater than 0, paint liquid waves
    if (progress > 0.005) {
      final waterLevelY = h * (1.0 - progress);

      // --- Background Wave (Lighter blue) ---
      final backWavePath = Path();
      const waveAmplitude = 7.0;
      const waveFrequency = 1.6;

      backWavePath.moveTo(0, h);
      backWavePath.lineTo(0, waterLevelY);

      for (double x = 0; x <= w; x += 3) {
        final y = waterLevelY +
            waveAmplitude *
                math.sin((x / w * 2 * math.pi * waveFrequency) + wavePhase + 1.2);
        backWavePath.lineTo(x, y);
      }

      backWavePath.lineTo(w, h);
      backWavePath.close();

      final backWavePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF60A5FA),
            Color(0xFF3B82F6),
          ],
        ).createShader(Rect.fromLTWH(0, waterLevelY - 10, w, h - waterLevelY + 10))
        ..style = PaintingStyle.fill;

      canvas.drawPath(backWavePath, backWavePaint);

      // --- Foreground Wave (Vibrant Blue matching design) ---
      final frontWavePath = Path();
      frontWavePath.moveTo(0, h);
      frontWavePath.lineTo(0, waterLevelY);

      for (double x = 0; x <= w; x += 3) {
        final y = waterLevelY +
            waveAmplitude *
                math.sin((x / w * 2 * math.pi * waveFrequency) - wavePhase);
        frontWavePath.lineTo(x, y);
      }

      frontWavePath.lineTo(w, h);
      frontWavePath.close();

      final frontWavePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2F9BFF),
            Color(0xFF1D4ED8),
          ],
        ).createShader(Rect.fromLTWH(0, waterLevelY - 10, w, h - waterLevelY + 10))
        ..style = PaintingStyle.fill;

      canvas.drawPath(frontWavePath, frontWavePaint);

      // Light surface sheen/highlight on top of water
      final highlightPaint = Paint()
        ..color = const Color(0x59FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(frontWavePath, highlightPaint);
    }

    canvas.restore();
  }

  Path _createDropletPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start at top sharp/rounded apex
    path.moveTo(w * 0.5, h * 0.02);

    // Right curve: flares down and rounds smoothly at the bottom
    path.cubicTo(
      w * 0.96, h * 0.38,
      w * 0.98, h * 0.72,
      w * 0.5, h * 0.98,
    );

    // Left curve: rounds back up symmetrically
    path.cubicTo(
      w * 0.02, h * 0.72,
      w * 0.04, h * 0.38,
      w * 0.5, h * 0.02,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _WaterDropletPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase;
  }
}
