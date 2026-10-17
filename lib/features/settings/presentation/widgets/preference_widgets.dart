import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Rounded card that groups preference rows (designs 51 / 49).
class PreferenceCard extends StatelessWidget {
  final List<Widget> children;

  const PreferenceCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: p.isDark ? Border.all(color: p.divider) : null,
      ),
      child: Column(children: children),
    );
  }
}

/// "Label ........ value v" row. [onTap] receives the row's own context so a
/// dropdown can anchor to it.
class PreferenceRow extends StatelessWidget {
  final String label;
  final String value;
  final void Function(BuildContext rowContext) onTap;

  const PreferenceRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Builder(
      builder: (rowContext) => InkWell(
        onTap: () => onTap(rowContext),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: p.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, color: p.textPrimary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class PreferenceSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PreferenceSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: p.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}

class PreferenceDivider extends StatelessWidget {
  const PreferenceDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: AppPalette.of(context).divider);
}
