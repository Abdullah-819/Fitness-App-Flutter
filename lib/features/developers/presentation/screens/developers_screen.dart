import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/developer.dart';
import '../widgets/developer_detail_popup.dart';

/// "Developers" page opened from Account. Each card animates in and opens the
/// developer's detail popup when tapped.
class DevelopersScreen extends StatefulWidget {
  const DevelopersScreen({super.key});

  @override
  State<DevelopersScreen> createState() => _DevelopersScreenState();
}

class _DevelopersScreenState extends State<DevelopersScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Animation<double> _stage(int i) {
    final start = (0.12 + i * 0.16).clamp(0.0, 0.7);
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(
        start,
        math.min(1.0, start + 0.45),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: p.textPrimary),
        title: Text(
          'Developers',
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _Reveal(
                  animation: _stage(0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18, top: 4),
                    child: Text(
                      'The team behind Smart Fitness & Step Counter. '
                      'Tap a profile to learn more.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.4,
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                ),
                for (var i = 0; i < kDevelopers.length; i++)
                  _Reveal(
                    animation: _stage(i + 1),
                    dx: i.isEven ? -36 : 36,
                    child: _DeveloperCard(developer: kDevelopers[i]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  /// Horizontal start offset in px (sign picks the side it slides in from).
  final double dx;

  const _Reveal({required this.animation, required this.child, this.dx = 0});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(
            (1 - animation.value) * dx,
            (1 - animation.value) * 28,
          ),
          child: Transform.scale(
            scale: 0.94 + 0.06 * animation.value,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DeveloperCard extends StatefulWidget {
  final Developer developer;

  const _DeveloperCard({required this.developer});

  @override
  State<_DeveloperCard> createState() => _DeveloperCardState();
}

class _DeveloperCardState extends State<_DeveloperCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final dev = widget.developer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Material(
          color: p.card,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => DeveloperDetailPopup.show(context, dev),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  DeveloperAvatar(developer: dev, size: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dev.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dev.role,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.3,
                            color: p.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    offset: Offset(_pressed ? 0.35 : 0, 0),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 22,
                      color: _pressed
                          ? AppColors.primaryPurple
                          : p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular developer photo with a slowly rotating purple gradient ring.
/// Shared via [Hero] between the list, the detail popup and the photo viewer.
class DeveloperAvatar extends StatefulWidget {
  final Developer developer;
  final double size;

  const DeveloperAvatar({
    super.key,
    required this.developer,
    required this.size,
  });

  @override
  State<DeveloperAvatar> createState() => _DeveloperAvatarState();
}

class _DeveloperAvatarState extends State<DeveloperAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final size = widget.size;

    return Hero(
      tag: widget.developer.heroTag,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (context, child) => Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.04),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              transform: GradientRotation(_spin.value * 2 * math.pi),
              colors: const [
                AppColors.primaryPurple,
                Color(0xFFB388FF),
                Color(0xFFFFD54A),
                AppColors.primaryPurple,
              ],
            ),
          ),
          child: child,
        ),
        child: Container(
          padding: EdgeInsets.all(size * 0.03),
          decoration: BoxDecoration(shape: BoxShape.circle, color: p.card),
          child: ClipOval(
            child: Image.asset(
              widget.developer.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: p.divider,
                child: Icon(
                  LucideIcons.user,
                  size: size * 0.45,
                  color: p.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
