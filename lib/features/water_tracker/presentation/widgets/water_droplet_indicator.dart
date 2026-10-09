import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A fluid water droplet gauge.
///
/// - The level rises/falls smoothly whenever [progress] changes.
/// - Two layered waves roll continuously inside the teardrop.
/// - Each time [splashTrigger] changes (water was added) a drop falls into the
///   water, ripples spread and the waves swell, then calm down.
/// - Bubbles drift up through the water and a glass highlight sits on the drop.
/// - [celebrate] adds a soft pulsing glow (daily goal reached).
/// - Honors the system "reduce motion" setting (no looping animation).
class WaterDropletIndicator extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double width;
  final double height;
  final bool animated;
  final bool isDark;
  final int splashTrigger;
  final bool celebrate;

  const WaterDropletIndicator({
    super.key,
    required this.progress,
    this.width = 170,
    this.height = 210,
    this.animated = true,
    this.isDark = false,
    this.splashTrigger = 0,
    this.celebrate = false,
  });

  @override
  State<WaterDropletIndicator> createState() => _WaterDropletIndicatorState();
}

class _WaterDropletIndicatorState extends State<WaterDropletIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _wave;
  late final AnimationController _splash;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    // value 1.0 == idle (no splash in progress)
    _splash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      value: 1.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _syncWave();
  }

  @override
  void didUpdateWidget(covariant WaterDropletIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWave();
    if (widget.splashTrigger != oldWidget.splashTrigger && !_reduceMotion) {
      _splash.forward(from: 0);
    }
  }

  void _syncWave() {
    final shouldRun = widget.animated && !_reduceMotion;
    if (shouldRun && !_wave.isAnimating) {
      _wave.repeat();
    } else if (!shouldRun && _wave.isAnimating) {
      _wave.stop();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    _splash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.progress.clamp(0.0, 1.0);

    return RepaintBoundary(
      // Smoothly animates the water level whenever the target changes.
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: target),
        duration: _reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 1400),
        curve: Curves.easeInOutCubic,
        builder: (context, level, _) {
          return AnimatedBuilder(
            animation: Listenable.merge([_wave, _splash]),
            builder: (context, _) {
              return CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _WaterDropletPainter(
                  progress: level,
                  wave: _wave.value,
                  splash: _splash.value,
                  isDark: widget.isDark,
                  celebrate: widget.celebrate,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Bubble {
  final double x; // 0..1 across the droplet
  final int speed; // whole cycles per wave loop (keeps the loop seamless)
  final double offset;
  final double radius;

  const _Bubble(this.x, this.speed, this.offset, this.radius);
}

class _WaterDropletPainter extends CustomPainter {
  final double progress;
  final double wave; // 0..1 looping
  final double splash; // 0..1, 1 == idle
  final bool isDark;
  final bool celebrate;

  static const _bubbles = [
    _Bubble(0.30, 1, 0.00, 3.2),
    _Bubble(0.48, 2, 0.35, 2.4),
    _Bubble(0.62, 1, 0.62, 4.0),
    _Bubble(0.40, 2, 0.80, 2.0),
    _Bubble(0.55, 1, 0.18, 2.8),
    _Bubble(0.70, 2, 0.50, 2.2),
  ];

  _WaterDropletPainter({
    required this.progress,
    required this.wave,
    required this.splash,
    required this.isDark,
    required this.celebrate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final phase = wave * 2 * math.pi;

    final dropletPath = _createDropletPath(size);

    // Idle float + jelly wobble after a splash (squash & stretch).
    final bob = math.sin(phase) * 2.5;
    final wobble = splash < 1.0
        ? math.sin(splash * math.pi * 7) * (1 - splash) * 0.05
        : 0.0;
    canvas.save();
    canvas.translate(w / 2, h / 2 + bob);
    canvas.scale(1 + wobble, 1 - wobble);
    canvas.translate(-w / 2, -h / 2);

    // 1. Outer ambient droplet (pulses softly when the goal is reached)
    final pulse = celebrate ? 1 + 0.05 * math.sin(phase) : 1.0;
    final outerPath = _createDropletPath(Size(w * 1.14 * pulse, h * 1.14 * pulse));
    canvas.save();
    canvas.translate(-w * (0.07 * pulse), -h * (0.07 * pulse));
    canvas.drawPath(
      outerPath,
      Paint()
        ..color = celebrate
            ? const Color(0x332F9BFF)
            : (isDark ? const Color(0xFF2A2D35) : const Color(0xFFF1F5F9))
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // 2. Empty droplet body
    canvas.drawPath(
      dropletPath,
      Paint()
        ..color = isDark ? const Color(0xFF3A3D45) : const Color(0xFFEBF3FE)
        ..style = PaintingStyle.fill,
    );
    // Soft drop shadow under the glass
    canvas.drawPath(
      dropletPath.shift(Offset(0, h * 0.03)),
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      dropletPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF4A4F5A), Color(0xFF2E3138)]
              : const [Color(0xFFF4F9FF), Color(0xFFDCEAFB)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    // Glass rim: bright on the lit side, faint on the far side
    canvas.drawPath(
      dropletPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.55 : 0.95),
            const Color(0xFF9CC3F0).withValues(alpha: 0.5),
            Colors.white.withValues(alpha: isDark ? 0.3 : 0.7),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // 3. Liquid, clipped to the droplet
    canvas.save();
    canvas.clipPath(dropletPath);

    if (progress > 0.005) {
      final waterLevelY = h * (1.0 - progress);
      // Waves swell right after water is added, then settle.
      final energy = math.pow(1 - splash, 2).toDouble();
      final amplitude = 6.0 + 10.0 * energy;
      final frequency = 1.6 + 0.5 * energy;

      Path wavePath(double shift, double dir) {
        final path = Path()
          ..moveTo(0, h)
          ..lineTo(0, waterLevelY);
        for (double x = 0; x <= w; x += 3) {
          final y = waterLevelY +
              amplitude *
                  math.sin((x / w * 2 * math.pi * frequency) + dir * phase + shift);
          path.lineTo(x, y);
        }
        return path
          ..lineTo(w, h)
          ..close();
      }

      final shaderRect =
          Rect.fromLTWH(0, waterLevelY - 12, w, h - waterLevelY + 12);

      // Back wave (lighter)
      canvas.drawPath(
        wavePath(1.2, 1),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
          ).createShader(shaderRect),
      );

      // Front wave (vibrant blue from the design)
      final front = wavePath(0, -1);
      canvas.drawPath(
        front,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F9BFF), Color(0xFF1D4ED8)],
          ).createShader(shaderRect),
      );
      canvas.drawPath(
        front,
        Paint()
          ..color = const Color(0x59FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // Depth shading: soft light from the top-left, darker at the bottom.
      canvas.drawRect(
        shaderRect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.5, -0.6),
            radius: 1.1,
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );

      // Foam dots riding the surface.
      for (var i = 0; i < 5; i++) {
        final fx = w * (0.18 + i * 0.16);
        final fy = waterLevelY +
            amplitude *
                math.sin((fx / w * 2 * math.pi * frequency) - phase);
        canvas.drawCircle(
          Offset(fx, fy),
          2.2 + (i % 2),
          Paint()..color = Colors.white.withValues(alpha: 0.45),
        );
      }

      _paintBubbles(canvas, w, h, waterLevelY);
      _paintSplash(canvas, w, h, waterLevelY);
    }

    canvas.restore();

    // Glass surface over the liquid: inner edge shading + refraction glow
    canvas.save();
    canvas.clipPath(dropletPath);
    canvas.drawPath(
      dropletPath,
      Paint()
        ..color = const Color(0xFF1E3A8A).withValues(alpha: isDark ? 0.35 : 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      dropletPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.14 : 0.35),
            Colors.transparent,
            const Color(0xFF93C5FD).withValues(alpha: 0.18),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    // Light caught at the bottom of the glass (caustic)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.93),
        width: w * 0.34,
        height: h * 0.05,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.18 : 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.restore();

    // Thin reflection on the right edge
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.80, h * 0.46)
        ..quadraticBezierTo(w * 0.86, h * 0.60, w * 0.76, h * 0.76),
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.15 : 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // 4. Glass highlight on the left edge
    final shine = Path()
      ..moveTo(w * 0.25, h * 0.50)
      ..quadraticBezierTo(w * 0.19, h * 0.64, w * 0.28, h * 0.77);
    canvas.drawPath(
      shine,
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.22 : 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(w * 0.31, h * 0.42),
      3,
      Paint()..color = Colors.white.withValues(alpha: isDark ? 0.3 : 0.8),
    );

    if (celebrate) _paintSparkles(canvas, w, h, phase);

    canvas.restore();
  }

  /// Twinkling four-point stars around the droplet (daily goal reached).
  void _paintSparkles(Canvas canvas, double w, double h, double phase) {
    const spots = [
      Offset(-0.02, 0.30),
      Offset(1.02, 0.45),
      Offset(0.08, 0.80),
      Offset(0.95, 0.85),
    ];
    for (var i = 0; i < spots.length; i++) {
      final tw = (math.sin(phase + i * 1.7) + 1) / 2; // 0..1
      final r = 3 + 6 * tw;
      final c = Offset(w * spots[i].dx, h * spots[i].dy);
      final star = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
        ..close();
      canvas.drawPath(
        star,
        Paint()..color = const Color(0xFF7DB8FF).withValues(alpha: 0.35 + 0.6 * tw),
      );
    }
  }

  void _paintBubbles(Canvas canvas, double w, double h, double waterLevelY) {
    final depth = h - waterLevelY;
    if (depth < 28) return;

    for (final b in _bubbles) {
      final t = (wave * b.speed + b.offset) % 1.0; // 0 bottom -> 1 surface
      final y = h - depth * t;
      if (y < waterLevelY + 10) continue;
      final x = w * b.x + math.sin(t * 2 * math.pi * 2 + b.offset * 6) * 4;
      final fade = (1 - t * t * t).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        b.radius,
        Paint()..color = Colors.white.withValues(alpha: 0.32 * fade),
      );
    }
  }

  /// A drop falls from the top into the water, then ripples spread.
  void _paintSplash(Canvas canvas, double w, double h, double waterLevelY) {
    if (splash >= 1.0) return;

    const fallEnd = 0.32;
    final cx = w / 2;

    if (splash < fallEnd) {
      final t = Curves.easeIn.transform(splash / fallEnd);
      final startY = h * 0.08;
      final y = startY + (waterLevelY - startY) * t;
      final dropPath = Path()
        ..moveTo(cx, y - 9)
        ..quadraticBezierTo(cx + 6, y, cx, y + 5)
        ..quadraticBezierTo(cx - 6, y, cx, y - 9)
        ..close();
      canvas.drawPath(dropPath, Paint()..color = const Color(0xFFBFE0FF));
      return;
    }

    final t = ((splash - fallEnd) / (1 - fallEnd)).clamp(0.0, 1.0);

    // Little droplets leap up from the impact and fall back in an arc.
    const sprays = [-1.0, -0.55, 0.55, 1.0, -0.2, 0.25];
    for (var i = 0; i < sprays.length; i++) {
      final st = (t * 1.6).clamp(0.0, 1.0);
      if (st >= 1.0) break;
      final vx = sprays[i];
      final lift = 26.0 + (i % 3) * 10;
      final px = cx + vx * w * 0.22 * st;
      final py = waterLevelY - lift * 4 * st * (1 - st);
      canvas.drawCircle(
        Offset(px, py),
        2.6 - (i % 2) * 0.8,
        Paint()..color = const Color(0xFFD6ECFF).withValues(alpha: 1 - st),
      );
    }

    for (var i = 0; i < 2; i++) {
      final rt = (t - i * 0.18).clamp(0.0, 1.0);
      if (rt == 0) continue;
      final eased = Curves.easeOut.transform(rt);
      final rect = Rect.fromCenter(
        center: Offset(cx, waterLevelY),
        width: w * (0.15 + 0.7 * eased),
        height: 10 + 12 * eased,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55 * (1 - rt))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  Path _createDropletPath(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..cubicTo(w * 0.96, h * 0.38, w * 0.98, h * 0.72, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.02, h * 0.72, w * 0.04, h * 0.38, w * 0.5, h * 0.02)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _WaterDropletPainter old) {
    return old.progress != progress ||
        old.wave != wave ||
        old.splash != splash ||
        old.isDark != isDark ||
        old.celebrate != celebrate;
  }
}
