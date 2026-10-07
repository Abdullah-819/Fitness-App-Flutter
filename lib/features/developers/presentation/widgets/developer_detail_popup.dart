import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_toast.dart';
import '../../data/developer.dart';
import '../screens/developers_screen.dart' show DeveloperAvatar;
import 'developer_photo_viewer.dart';

/// Animated popup with a developer's full details. Tap the photo to view it
/// full screen.
///
/// Implemented as a transparent [PageRouteBuilder] (not a dialog route) so the
/// avatar [Hero] can fly between the list, this popup and the photo viewer.
class DeveloperDetailPopup extends StatelessWidget {
  final Developer developer;
  final Animation<double> animation;

  const DeveloperDetailPopup({
    super.key,
    required this.developer,
    required this.animation,
  });

  static Future<void> show(BuildContext context, Developer developer) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: 'Close',
        barrierColor: Colors.black.withValues(alpha: 0.35),
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, _) =>
            DeveloperDetailPopup(developer: developer, animation: animation),
      ),
    );
  }

  Animation<double> _stage(double begin, double end) => CurvedAnimation(
    parent: animation,
    curve: Interval(begin, end, curve: Curves.easeOutCubic),
  );

  Widget _reveal(Animation<double> a, Widget child) => AnimatedBuilder(
    animation: a,
    child: child,
    builder: (context, child) => Opacity(
      opacity: a.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - a.value) * 16),
        child: child,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final cardIn = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    final size = MediaQuery.sizeOf(context);
    final avatar = (size.width * 0.34).clamp(96.0, 140.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Blur + dim backdrop that also closes the popup on tap.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8 * animation.value,
                sigmaY: 8 * animation.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(cardIn),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0, 0.5),
                    ),
                    child: Material(
                      color: p.card,
                      elevation: 12,
                      shadowColor: Colors.black54,
                      borderRadius: BorderRadius.circular(28),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Purple header glow
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            height: 150,
                            child: _BreathingGlow(isDark: p.isDark),
                          ),
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ScaleTransition(
                                  scale: CurvedAnimation(
                                    parent: animation,
                                    curve: const Interval(
                                      0.05,
                                      0.55,
                                      curve: Curves.elasticOut,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => DeveloperPhotoViewer.show(
                                      context,
                                      developer,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        DeveloperAvatar(
                                          developer: developer,
                                          size: avatar,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryPurple,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: p.card,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            LucideIcons.maximize2,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _reveal(
                                  _stage(0.25, 0.6),
                                  Column(
                                    children: [
                                      Text(
                                        developer.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.4,
                                          color: p.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        developer.role,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          height: 1.35,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _reveal(
                                  _stage(0.38, 0.72),
                                  Text(
                                    developer.bio,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      height: 1.5,
                                      color: p.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _reveal(
                                  _stage(0.48, 0.82),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (
                                        var i = 0;
                                        i < developer.focusAreas.length;
                                        i++
                                      )
                                        ScaleTransition(
                                          scale: CurvedAnimation(
                                            parent: animation,
                                            curve: Interval(
                                              (0.5 + i * 0.08).clamp(0.0, 0.9),
                                              (0.78 + i * 0.08).clamp(0.0, 1.0),
                                              curve: Curves.easeOutBack,
                                            ),
                                          ),
                                          child: _Chip(
                                            label: developer.focusAreas[i],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _reveal(
                                  _stage(0.58, 0.95),
                                  _DetailRows(
                                    developer: developer,
                                    animation: animation,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: Icon(LucideIcons.x, color: p.textSecondary),
                              tooltip: 'Close',
                            ),
                          ),
                        ],
                      ),
                    ),
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

/// Header gradient whose intensity gently pulses.
class _BreathingGlow extends StatefulWidget {
  final bool isDark;

  const _BreathingGlow({required this.isDark});

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final base = widget.isDark ? 0.30 : 0.18;
        final alpha = base + 0.12 * Curves.easeInOut.transform(_c.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryPurple.withValues(alpha: alpha),
                AppColors.primaryPurple.withValues(alpha: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryPurple,
        ),
      ),
    );
  }
}

/// GitHub link plus any optional details (email, location, LinkedIn) that
/// have been filled in for this developer.
class _DetailRows extends StatelessWidget {
  final Developer developer;
  final Animation<double> animation;

  const _DetailRows({required this.developer, required this.animation});

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (LucideIcons.code, '@${developer.githubUsername}', developer.githubUrl),
      if (developer.email != null)
        (LucideIcons.mail, developer.email!, developer.email!),
      if (developer.location != null)
        (LucideIcons.mapPin, developer.location!, developer.location!),
      if (developer.linkedIn != null)
        (LucideIcons.link, 'LinkedIn', developer.linkedIn!),
    ];

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(
                ((animation.value - (0.62 + i * 0.07)) / 0.3).clamp(0.0, 1.0),
              );
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset((1 - t) * 40, 0),
                  child: child,
                ),
              );
            },
            child: _DetailRow(
              icon: rows[i].$1,
              label: rows[i].$2,
              copyValue: rows[i].$3,
            ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String copyValue;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.copyValue,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: p.background.withValues(alpha: p.isDark ? 0.5 : 0.7),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Clipboard.setData(ClipboardData(text: copyValue));
            HapticFeedback.selectionClick();
            AppToast.success('Copied to clipboard');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 20, color: p.textPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: p.textPrimary,
                    ),
                  ),
                ),
                Icon(LucideIcons.copy, size: 16, color: p.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
