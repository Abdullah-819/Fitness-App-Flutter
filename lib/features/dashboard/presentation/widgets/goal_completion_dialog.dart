import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Full-screen celebration displayed when the user reaches their step goal.
///
/// Real confetti cannons + falling confetti (the `confetti` package), a
/// trophy that drops in with a bounce, rotating light rays, a shockwave ring,
/// a shine sweep and twinkling stars, then staggered text, stats and buttons.
class GoalCompletionDialog extends StatefulWidget {
  final int stepGoal;
  final String durationString;
  final String caloriesString;
  final String distanceKmString;
  final VoidCallback onStopStep;
  final VoidCallback onContinueSteps;

  const GoalCompletionDialog({
    super.key,
    required this.stepGoal,
    required this.durationString,
    required this.caloriesString,
    required this.distanceKmString,
    required this.onStopStep,
    required this.onContinueSteps,
  });

  /// Displays the full-screen celebration. Resolves to true when the user
  /// continues, false when they stop.
  static Future<bool?> show({
    required BuildContext context,
    required int stepGoal,
    required String durationString,
    required String caloriesString,
    required String distanceKmString,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Goal completed',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (dialogContext, _, _) => GoalCompletionDialog(
        stepGoal: stepGoal,
        durationString: durationString,
        caloriesString: caloriesString,
        distanceKmString: distanceKmString,
        onStopStep: () => Navigator.of(dialogContext).pop(false),
        onContinueSteps: () => Navigator.of(dialogContext).pop(true),
      ),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }

  @override
  State<GoalCompletionDialog> createState() => _GoalCompletionDialogState();
}

class _GoalCompletionDialogState extends State<GoalCompletionDialog>
    with TickerProviderStateMixin {
  static const _confettiColors = <Color>[
    Color(0xFF7C4DFF),
    Color(0xFFB388FF),
    Color(0xFFFFD54A),
    Color(0xFFFF9500),
    Color(0xFFFF453A),
    Color(0xFF34C759),
    Color(0xFF40C4FF),
    Color(0xFFFF6FB5),
  ];

  late final AnimationController _intro;
  late final AnimationController _loop;
  late final ConfettiController _cannonLeft;
  late final ConfettiController _cannonRight;
  late final ConfettiController _burst;
  late final ConfettiController _rain;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _cannonLeft = ConfettiController(duration: const Duration(seconds: 2));
    _cannonRight = ConfettiController(duration: const Duration(seconds: 2));
    _burst = ConfettiController(duration: const Duration(milliseconds: 900));
    _rain = ConfettiController(duration: const Duration(seconds: 6));

    // Fire in sequence for a layered, proper party feel.
    _burst.play();
    HapticFeedback.heavyImpact();
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _cannonLeft.play();
      _cannonRight.play();
      HapticFeedback.mediumImpact();
    });
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _rain.play();
      HapticFeedback.lightImpact();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    _cannonLeft.dispose();
    _cannonRight.dispose();
    _burst.dispose();
    _rain.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Animation that plays over [begin]..[end] (0-1) of the intro timeline.
  Animation<double> _stage(double begin, double end, [Curve? curve]) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: curve ?? Curves.easeOutCubic),
    );
  }

  Widget _reveal(Animation<double> a, Widget child, {double dy = 24}) {
    return AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * dy),
          child: child,
        ),
      ),
    );
  }

  /// A confetti emitter. Particles are star/rect shapes in the party palette.
  Widget _confettiEmitter(
    ConfettiController controller, {
    double direction = -math.pi / 2,
    BlastDirectionality directionality = BlastDirectionality.directional,
    double blastForce = 40,
    double minForce = 12,
    double frequency = 0.05,
    int particles = 18,
    double gravity = 0.25,
    Path Function(Size)? shape,
  }) {
    return ConfettiWidget(
      confettiController: controller,
      blastDirection: direction,
      blastDirectionality: directionality,
      emissionFrequency: frequency,
      numberOfParticles: particles,
      maxBlastForce: blastForce,
      minBlastForce: minForce,
      gravity: gravity,
      colors: _confettiColors,
      minimumSize: const Size(8, 5),
      maximumSize: const Size(15, 9),
      particleDrag: 0.05,
      createParticlePath: shape,
      shouldLoop: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final size = MediaQuery.sizeOf(context);
    final titleIn = _stage(0.25, 0.45);
    final subtitleIn = _stage(0.32, 0.52);
    final statsIn = _stage(0.50, 1.0, Curves.linear);
    final buttonsIn = _stage(0.55, 0.80);

    return PopScope(
      canPop: false,
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.85,
        maxScaleFactor: 1.15,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Backdrop: soft purple spotlight over the themed background
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.35),
                    radius: 1.1,
                    colors: [
                      Color.alphaBlend(
                        AppColors.primaryPurple.withValues(alpha: 0.28),
                        p.background,
                      ),
                      p.background,
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: size.height * 0.5,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildHero(p, size, titleIn, subtitleIn),
                                    const SizedBox(height: 28),

                                    _buildStats(p, statsIn),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _reveal(buttonsIn, _buildButtons(), dy: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Quick light flash as the celebration kicks off.
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _intro,
                  builder: (context, _) {
                    final t = (_intro.value / 0.10).clamp(0.0, 1.0);
                    return ColoredBox(
                      color: Colors.white.withValues(alpha: 0.45 * (1 - t)),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),

              // Confetti sits above the content but never blocks taps.
              IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Explosive pop from behind the trophy
                    Align(
                      alignment: const Alignment(0, -0.45),
                      child: _confettiEmitter(
                        _burst,
                        directionality: BlastDirectionality.explosive,
                        blastForce: 38,
                        minForce: 10,
                        frequency: 0.4,
                        particles: 28,
                        gravity: 0.18,
                        shape: _starPath,
                      ),
                    ),
                    // Cannons from the bottom corners
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: _confettiEmitter(
                        _cannonLeft,
                        direction: -math.pi / 3, // up and to the right
                        blastForce: 70,
                        minForce: 30,
                        frequency: 0.06,
                        particles: 16,
                        gravity: 0.3,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: _confettiEmitter(
                        _cannonRight,
                        direction: -2 * math.pi / 3, // up and to the left
                        blastForce: 70,
                        minForce: 30,
                        frequency: 0.06,
                        particles: 16,
                        gravity: 0.3,
                      ),
                    ),
                    // Gentle rain from the top
                    Align(
                      alignment: Alignment.topCenter,
                      child: _confettiEmitter(
                        _rain,
                        direction: math.pi / 2, // downwards
                        directionality: BlastDirectionality.explosive,
                        blastForce: 9,
                        minForce: 2,
                        frequency: 0.03,
                        particles: 6,
                        gravity: 0.08,
                        shape: _starPath,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The glowing circle that holds the trophy, the title and the subtitle.
  Widget _buildHero(
    AppPalette p,
    Size screen,
    Animation<double> titleIn,
    Animation<double> subtitleIn,
  ) {
    final d = math.min(screen.width - 48, math.min(380.0, screen.height * 0.5));
    final trophySize = d * 0.46;

    // Startup: circle pops in with an elastic scale, then a ring draws itself.
    final circleIn = _stage(0.0, 0.28, Curves.elasticOut);
    final ringDraw = _stage(0.04, 0.40, Curves.easeInOutCubic);

    return AnimatedBuilder(
      animation: Listenable.merge([_loop, _intro]),
      builder: (context, child) {
        final glow = 0.5 + 0.5 * math.sin(_loop.value * 2 * math.pi);
        return Transform.scale(
          scale: circleIn.value.clamp(0.0, 1.15),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _heroCircle(d, glow, child!),
              IgnorePointer(
                child: CustomPaint(
                  size: Size.square(d),
                  painter: _ProgressRingPainter(
                    progress: ringDraw.value,
                    spin: _loop.value,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: _heroContent(p, d, trophySize, titleIn, subtitleIn),
    );
  }

  Widget _heroCircle(double d, double glow, Widget child) {
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.30),
            AppColors.primaryPurple.withValues(alpha: 0.07),
          ],
        ),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.30 + 0.2 * glow),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(
              alpha: 0.18 + 0.14 * glow,
            ),
            blurRadius: 30 + 14 * glow,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(child: child),
    );
  }

  Widget _heroContent(
    AppPalette p,
    double d,
    double trophySize,
    Animation<double> titleIn,
    Animation<double> subtitleIn,
  ) {
    // One-off shimmer that sweeps across the title after it appears.
    final shimmer = _stage(0.40, 0.62, Curves.easeInOut);

    return Padding(
      padding: EdgeInsets.all(d * 0.07),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTrophy(trophySize),
              const SizedBox(height: 6),
              _reveal(
                titleIn,
                AnimatedBuilder(
                  animation: _intro,
                  builder: (context, child) {
                    final pos = shimmer.value * 1.6 - 0.3;
                    // Title also pops slightly as it lands.
                    final pop = 1 + 0.12 * math.sin(titleIn.value * math.pi);
                    return Transform.scale(
                      scale: pop,
                      child: ShaderMask(
                        blendMode: BlendMode.srcATop,
                        shaderCallback: (rect) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: const [
                            Color(0x00FFD54A),
                            Color(0xFFFFD54A),
                            Color(0x00FFD54A),
                          ],
                          stops: [
                            (pos - 0.18).clamp(0.0, 1.0),
                            pos.clamp(0.0, 1.0),
                            (pos + 0.18).clamp(0.0, 1.0),
                          ],
                        ).createShader(rect),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    '${_formatNumber(widget.stepGoal)} Steps!',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: p.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _reveal(
                subtitleIn,
                Text(
                  "Congratulations!\nYou've completed the step goal.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: p.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy(double size) {
    // Intro pieces: drop with bounce, pop scale, one-off shockwave ring.
    final drop = _stage(0.0, 0.42, Curves.bounceOut);
    final pop = _stage(0.0, 0.25, Curves.easeOutBack);
    final shock = _stage(0.16, 0.55, Curves.easeOutCubic);

    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _loop]),
      builder: (context, _) {
        final t = _loop.value * 2 * math.pi;
        final float = math.sin(t) * 6; // gentle hover
        final glow = 0.5 + 0.5 * math.sin(t); // 0..1 pulse
        final appear = pop.value.clamp(0.0, 1.0);
        final shine = (_loop.value * 1.6) - 0.3; // sweep position, with pauses

        // Squash on landing: the bounce curve overshoots toward the end.
        final dropDy = (1 - drop.value) * -size * 1.1;
        final heartbeat = 1 + 0.025 * math.max(0, math.sin(t * 2));

        return SizedBox(
          width: size * 1.35,
          height: size * 1.1,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Rotating light rays
              Opacity(
                opacity: appear * 0.55,
                child: Transform.rotate(
                  angle: _loop.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size.square(size * 1.35),
                    painter: _RaysPainter(),
                  ),
                ),
              ),

              // Pulsing golden glow
              Container(
                width: size * (0.85 + 0.08 * glow),
                height: size * (0.85 + 0.08 * glow),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFC83D)
                          .withValues(alpha: (0.34 + 0.2 * glow) * appear),
                      const Color(0xFFFFC83D).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),

              // One-off shockwave ring when the trophy lands
              if (shock.value > 0 && shock.value < 1)
                Container(
                  width: size * (0.4 + shock.value * 1.0),
                  height: size * (0.4 + shock.value * 1.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD54A)
                          .withValues(alpha: (1 - shock.value) * 0.8),
                      width: 4 * (1 - shock.value) + 1,
                    ),
                  ),
                ),

              // Twinkling stars around the trophy
              for (final s in _stars)
                Positioned(
                  left: size * 0.675 + s.dx * size * 0.66 - 9,
                  top: size * 0.55 + s.dy * size * 0.55 - 9,
                  child: Opacity(
                    opacity:
                        (appear *
                                (0.3 +
                                    0.7 *
                                        math.max(0, math.sin(t * 2 + s.phase))))
                            .toDouble(),
                    child: Transform.scale(
                      scale: 0.5 + 0.7 * math.max(0, math.sin(t * 2 + s.phase)),
                      child: Transform.rotate(
                        angle: t + s.phase,
                        child: Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: s.color,
                        ),
                      ),
                    ),
                  ),
                ),

              // Trophy: drops in, bounces, hovers, sways and glints
              Transform.translate(
                offset: Offset(0, dropDy + float),
                child: Transform.scale(
                  scale: appear * heartbeat,
                  child: Transform.rotate(
                    angle: math.sin(t) * 0.035 + (1 - appear) * -0.4,
                    child: ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (rect) => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: const [
                          Color(0x00FFFFFF),
                          Color(0x99FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                        stops: [
                          (shine - 0.15).clamp(0.0, 1.0),
                          shine.clamp(0.0, 1.0),
                          (shine + 0.15).clamp(0.0, 1.0),
                        ],
                      ).createShader(rect),
                      child: Image.asset(
                        AppAssets.goalCompletionTrophy,
                        width: size,
                        height: size * 0.88,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: size * 0.6,
                          height: size * 0.6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF7DF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: const Color(0xFFFFB800),
                            size: size * 0.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Five-point star used for some of the confetti pieces.
  static Path _starPath(Size size) {
    final path = Path();
    final c = size.center(Offset.zero);
    final outer = size.width / 2;
    final inner = outer * 0.45;
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  }

  static const _stars = <_Star>[
    _Star(-0.95, -0.55, 0.0, Color(0xFFFFD54A)),
    _Star(0.95, -0.45, 1.6, Color(0xFFFFB300)),
    _Star(-0.75, 0.35, 3.1, Color(0xFFFFE082)),
    _Star(0.85, 0.30, 4.4, Color(0xFFFFD54A)),
    _Star(-0.30, -0.95, 2.2, Color(0xFFFFFFFF)),
    _Star(0.35, -0.90, 5.0, Color(0xFFFFE082)),
  ];

  /// Replaces each number in [value] ("1h 30m", "432", "6.90") with its
  /// share [t] (0-1) of the final figure, keeping the original formatting.
  static String _countUp(String value, double t) {
    return value.replaceAllMapped(RegExp(r'\d+\.?\d*'), (m) {
      final raw = m.group(0)!;
      final target = double.tryParse(raw);
      if (target == null) return raw;
      final decimals = raw.contains('.') ? raw.split('.').last.length : 0;
      return (target * t).toStringAsFixed(decimals);
    });
  }

  Widget _buildStats(AppPalette p, Animation<double> a) {
    final items = <(IconData, Color, String, String)>[
      (
        LucideIcons.clock,
        const Color(0xFFFF9500),
        widget.durationString,
        'time',
      ),
      (
        LucideIcons.flame,
        const Color(0xFFFF453A),
        widget.caloriesString,
        'kcal',
      ),
      (LucideIcons.mapPin, AppColors.success, widget.distanceKmString, 'km'),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Container(height: 44, width: 1, color: p.divider),
          Expanded(
            // Each metric pops in a beat after the previous one.
            child: AnimatedBuilder(
              animation: a,
              builder: (context, child) {
                final local = Curves.easeOutBack.transform(
                  ((a.value - i * 0.18) / 0.64).clamp(0.0, 1.0),
                );
                final appear = (local * 3).clamp(0.0, 1.0);
                // Numbers count up from 0 to the achieved value, one after another.
                final count = Curves.easeOutCubic.transform(
                  ((a.value - i * 0.14) / 0.6).clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: appear,
                  child: Transform.scale(
                    scale: 0.7 + 0.3 * local,
                    child: _SummaryMetric(
                      icon: items[i].$1,
                      iconColor: items[i].$2,
                      value: _countUp(items[i].$3, count),
                      label: items[i].$4,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: TextButton(
              onPressed: widget.onStopStep,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.lightPurpleBg,
                foregroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Stop Step',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AnimatedBuilder(
            animation: _loop,
            builder: (context, child) {
              final glow = 0.5 + 0.5 * math.sin(_loop.value * 2 * math.pi);
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(
                        alpha: 0.25 + 0.30 * glow,
                      ),
                      blurRadius: 12 + 12 * glow,
                      spreadRadius: 1 * glow,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: widget.onContinueSteps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Continue Steps',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Star {
  final double dx;
  final double dy;
  final double phase;
  final Color color;

  const _Star(this.dx, this.dy, this.phase, this.color);
}

/// Gradient ring that draws itself around the hero circle, then keeps a
/// bright comet spinning along it.
class _ProgressRingPainter extends CustomPainter {
  final double progress; // 0-1 draw-in
  final double spin; // 0-1 loop

  _ProgressRingPainter({required this.progress, required this.spin});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - 2,
    );

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF7C4DFF),
          Color(0xFFB388FF),
          Color(0xFFFFD54A),
          Color(0xFF7C4DFF),
        ],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, ring);

    // Comet that keeps orbiting once the ring is drawn.
    if (progress >= 1) {
      final comet = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawArc(
        rect,
        spin * 2 * math.pi - math.pi / 2,
        0.35,
        false,
        comet,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress || old.spin != spin;
}

/// Soft sunburst rays drawn behind the trophy.
class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const rays = 12;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD54A).withValues(alpha: 0.55),
          const Color(0xFFFFD54A).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (var i = 0; i < rays; i++) {
      final start = i * 2 * math.pi / rays;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        math.pi / rays, // half the slot is lit, half is dark
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter oldDelegate) => false;
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _SummaryMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: p.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: p.textSecondary,
          ),
        ),
      ],
    );
  }
}
