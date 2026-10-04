import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/track_map_style.dart';

/// Round "layers" button that opens the map style picker. Sits at the top
/// right of the map so it is never covered by the START button or stats sheet.
class TrackMapStyleButton extends StatelessWidget {
  final TrackMapStyle style;
  final ValueChanged<TrackMapStyle> onChanged;

  const TrackMapStyleButton({
    super.key,
    required this.style,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Material(
      color: p.card,
      elevation: 4,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        key: const Key('map_style_button'),
        customBorder: const CircleBorder(),
        onTap: () async {
          final picked = await showModalBottomSheet<TrackMapStyle>(
            context: context,
            backgroundColor: p.card,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => _StyleSheet(selected: style),
          );
          if (picked != null) onChanged(picked);
        },
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(LucideIcons.layers, color: p.textPrimary, size: 24),
        ),
      ),
    );
  }
}

class _StyleSheet extends StatelessWidget {
  final TrackMapStyle selected;

  const _StyleSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Map type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            for (final style in TrackMapStyle.values)
              InkWell(
                key: Key('map_style_${style.name}'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).pop(style),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(style.icon, size: 24, color: p.textPrimary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              style.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: p.textPrimary,
                              ),
                            ),
                            Text(
                              style.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: p.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        style == selected
                            ? LucideIcons.circleCheck
                            : LucideIcons.circle,
                        size: 22,
                        color: style == selected
                            ? AppColors.primaryPurple
                            : p.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
