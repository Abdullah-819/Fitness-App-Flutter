import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../splash/presentation/widgets/footprints_icon.dart';
import '../../data/models/history_record_model.dart';

/// Single activity history record tile supporting swipe-to-delete matching
/// `design/History/34_Dark_history.png` and `35_Dark_history - delete action.png`.
class HistoryRecordTile extends StatelessWidget {
  final HistoryRecordModel record;
  final VoidCallback onDelete;

  const HistoryRecordTile({
    super.key,
    required this.record,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      resizeDuration: const Duration(milliseconds: 250),
      movementDuration: const Duration(milliseconds: 250),
      dismissThresholds: const {DismissDirection.endToStart: 0.4},
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF381E24), // subtle red-tinted dark background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEC2727).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.trash2,
            color: Color(0xFFEC2727),
            size: 22,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: palette.border.withValues(
              alpha: palette.isDark ? 0.25 : 0.6,
            ),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _Metric(
              flex: 3,
              icon: const FootprintsIcon(
                size: 20,
                color: AppColors.primaryPurple,
              ),
              text: record.formattedSteps,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
            _Metric(
              flex: 3,
              icon: const Icon(
                LucideIcons.clock,
                size: 17,
                color: Color(0xFFFF9500),
              ),
              text: record.formattedTime,
              color: palette.textPrimary,
            ),
            _Metric(
              flex: 2,
              icon: const Icon(
                LucideIcons.flame,
                size: 17,
                color: Color(0xFFFF4B4B),
              ),
              text: '${record.calories}',
              color: palette.textPrimary,
            ),
            _Metric(
              flex: 2,
              icon: const Icon(
                LucideIcons.mapPin,
                size: 17,
                color: Color(0xFF22C55E),
              ),
              text: record.distanceKm.toStringAsFixed(2),
              color: palette.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

/// One icon + value cell. The value scales down instead of truncating so it
/// stays readable on narrow phones.
class _Metric extends StatelessWidget {
  final int flex;
  final Widget icon;
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const _Metric({
    required this.flex,
    required this.icon,
    required this.text,
    required this.color,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 5),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
