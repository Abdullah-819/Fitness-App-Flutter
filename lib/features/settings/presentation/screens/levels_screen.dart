import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

class LevelsScreen extends StatelessWidget {
  final int level;

  const LevelsScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final progress = (level / (level + 1)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Levels',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: p.isDark ? Border.all(color: p.divider) : null,
            ),
            child: Column(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFC83D), Color(0xFFFF7A1A)],
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.medal,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Level $level',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You are a rising star!',
                  style: TextStyle(color: p.textSecondary),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: p.divider,
                  color: AppColors.primaryPurple,
                ),
                const SizedBox(height: 8),
                Text(
                  '${level * 100} / ${(level + 1) * 100} points to Level ${level + 1}',
                  style: TextStyle(fontSize: 13, color: p.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Milestones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final milestone in const [
            ('First steps', 'Started your TrackFit journey'),
            ('Consistent tracker', 'Logged fitness progress'),
            ('Rising star', 'Keep building healthy habits'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MilestoneTile(
                title: milestone.$1,
                subtitle: milestone.$2,
                palette: p,
              ),
            ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final AppPalette palette;

  const _MilestoneTile({
    required this.title,
    required this.subtitle,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
        border: palette.isDark ? Border.all(color: palette.divider) : null,
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.circleCheck, color: AppColors.primaryPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
