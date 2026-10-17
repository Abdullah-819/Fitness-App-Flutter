import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/weight_models.dart';

/// Purple line chart with a gradient fill, ringed points and a pin tooltip
/// on the selected point. The line draws in on first show and on new data.
class WeightLineChart extends StatefulWidget {
  final List<WeightEntry> entries;

  const WeightLineChart({super.key, required this.entries});

  @override
  State<WeightLineChart> createState() => _WeightLineChartState();
}

class _WeightLineChartState extends State<WeightLineChart>
    with SingleTickerProviderStateMixin {
  static const double _height = 220;
  static const double _axisWidth = 30;
  static const double _labelHeight = 28;

  late final AnimationController _entrance;
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = _defaultSelection();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _entrance.value = 1;
    } else if (!_entrance.isAnimating && _entrance.value == 0) {
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(covariant WeightLineChart old) {
    super.didUpdateWidget(old);
    if (!identical(old.entries, widget.entries)) {
      _selected = _defaultSelection();
      _entrance.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// Second-to-last point, like the design; the only point when there is one.
  int _defaultSelection() => math.max(0, widget.entries.length - 2);

  double get _lo =>
      widget.entries.map((e) => e.kg).reduce(math.min).floorToDouble() - 2;
  double get _hi =>
      widget.entries.map((e) => e.kg).reduce(math.max).ceilToDouble();

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    if (widget.entries.isEmpty) {
      return SizedBox(
        height: _height,
        child: Center(
          child: Text(
            'No weight logged yet',
            style: TextStyle(color: p.textSecondary),
          ),
        ),
      );
    }

    final lo = _lo;
    final hi = math.max(_hi, lo + 1);
    final step = math.max(1, ((hi - lo) / 5).ceil());
    final ticks = <double>[for (var v = lo; v <= hi; v += step) v];

    return LayoutBuilder(
      builder: (context, constraints) {
        final plotWidth = constraints.maxWidth - _axisWidth;
        const plotHeight = _height - _labelHeight;
        final n = widget.entries.length;
        final dx = n == 1 ? 0.0 : (plotWidth - 24) / (n - 1);
        Offset pointAt(int i) => Offset(
          12 + i * dx + (n == 1 ? (plotWidth - 24) / 2 : 0),
          plotHeight - (widget.entries[i].kg - lo) / (hi - lo) * plotHeight,
        );

        return SizedBox(
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Y axis labels
              for (final t in ticks)
                Positioned(
                  left: 0,
                  top: plotHeight - (t - lo) / (hi - lo) * plotHeight - 8,
                  child: Text(
                    t.round().toString(),
                    style: TextStyle(fontSize: 13, color: p.textSecondary),
                  ),
                ),

              // Plot
              Positioned(
                left: _axisWidth,
                top: 0,
                width: plotWidth,
                height: plotHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) {
                    var best = 0;
                    var bestDist = double.infinity;
                    for (var i = 0; i < n; i++) {
                      final dist = (pointAt(i).dx - d.localPosition.dx).abs();
                      if (dist < bestDist) {
                        best = i;
                        bestDist = dist;
                      }
                    }
                    if (best != _selected) {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = best);
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _entrance,
                    builder: (context, _) => CustomPaint(
                      painter: _LinePainter(
                        points: [for (var i = 0; i < n; i++) pointAt(i)],
                        selected: _selected,
                        progress: Curves.easeOutCubic.transform(
                          _entrance.value,
                        ),
                        ringFill: p.card,
                      ),
                    ),
                  ),
                ),
              ),

              // Tooltip pin
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: _axisWidth + pointAt(_selected).dx - 22,
                top: pointAt(_selected).dy - 66,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: Interval(0.6, 1).transform(_entrance.value),
                    child: _Pin(kg: widget.entries[_selected].kg),
                  ),
                ),
              ),

              // X axis labels
              for (var i = 0; i < n; i++)
                if (n <= 7 || i % 2 == 0)
                  Positioned(
                    left: _axisWidth + pointAt(i).dx - 20,
                    top: plotHeight + 12,
                    width: 40,
                    child: Text(
                      monthAbbr[widget.entries[i].date.month - 1],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: p.textSecondary),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _Pin extends StatelessWidget {
  final double kg;

  const _Pin({required this.kg});

  @override
  Widget build(BuildContext context) {
    final text = kg == kg.roundToDouble()
        ? kg.round().toString()
        : kg.toStringAsFixed(1);
    return SizedBox(
      width: 44,
      height: 58,
      child: CustomPaint(
        painter: _PinPainter(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.05,
                ),
              ),
              const Text(
                'kg',
                style: TextStyle(fontSize: 8, color: Colors.black54, height: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final circleCenter = Offset(r, r);
    final path = Path()
      ..addOval(Rect.fromCircle(center: circleCenter, radius: r - 2))
      ..moveTo(r - 7, r + r - 6)
      ..lineTo(r, size.height - 4)
      ..lineTo(r + 7, r + r - 6)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.primaryPurple,
    );
    // Cover the stroke seam between circle and tip.
    canvas.drawRect(
      Rect.fromLTWH(r - 6, r + r - 8, 12, 4),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _LinePainter extends CustomPainter {
  final List<Offset> points;
  final int selected;
  final double progress;
  final Color ringFill;

  _LinePainter({
    required this.points,
    required this.selected,
    required this.progress,
    required this.ringFill,
  });

  /// Smooth-ish path; straight segments match the design's sharp corners.
  Path _linePath() {
    final path = Path()..moveTo(0, points.first.dy);
    path.lineTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      path.lineTo(pt.dx, pt.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final line = _linePath();
    final metric = line.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);

    // Gradient fill under the drawn portion.
    final tip = metric.getTangentForOffset(metric.length * progress)!.position;
    final fill = Path.from(drawn)
      ..lineTo(tip.dx, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.28),
            AppColors.primaryPurple.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primaryPurple,
    );

    for (var i = 0; i < points.length; i++) {
      // Reveal each dot as the line reaches it.
      final reached = points[i].dx <= tip.dx + 0.5;
      if (!reached) continue;
      canvas.drawCircle(points[i], 7, Paint()..color = ringFill);
      canvas.drawCircle(
        points[i],
        7,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = AppColors.primaryPurple,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.progress != progress ||
      old.selected != selected ||
      old.points != points ||
      old.ringFill != ringFill;
}
