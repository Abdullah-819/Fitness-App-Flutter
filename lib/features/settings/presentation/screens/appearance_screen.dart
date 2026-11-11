import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/theme_controller.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  static const _options = [
    (mode: ThemeMode.light, label: 'Light', icon: LucideIcons.sun),
    (mode: ThemeMode.dark, label: 'Dark', icon: LucideIcons.moon),
    (
      mode: ThemeMode.system,
      label: 'System default',
      icon: LucideIcons.smartphone,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final controller = context.watch<ThemeController>();

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
          'App Appearance',
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
          Text(
            'Choose how TrackFit looks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your selection is saved automatically and applies across the app.',
            style: TextStyle(fontSize: 14, color: p.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(16),
              border: p.isDark ? Border.all(color: p.divider) : null,
            ),
            child: Row(
              children: [
                Icon(
                  controller.mode == ThemeMode.dark
                      ? LucideIcons.moon
                      : LucideIcons.sun,
                  size: 28,
                  color: AppColors.primaryPurple,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _labelFor(controller.mode),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'Current',
                  style: TextStyle(fontSize: 13, color: p.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(16),
              border: p.isDark ? Border.all(color: p.divider) : null,
            ),
            child: Column(
              children: [
                for (var i = 0; i < _options.length; i++) ...[
                  _AppearanceOption(
                    label: _options[i].label,
                    icon: _options[i].icon,
                    selected: controller.mode == _options[i].mode,
                    onTap: () => controller.setMode(_options[i].mode),
                  ),
                  if (i < _options.length - 1)
                    Divider(height: 1, color: p.divider),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }
}

class _AppearanceOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: p.textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
            ),
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 22,
              color: selected ? AppColors.primaryPurple : p.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
