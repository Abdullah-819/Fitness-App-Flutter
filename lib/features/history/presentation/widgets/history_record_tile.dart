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

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: palette.border.withValues(alpha: palette.isDark ? 0.25 : 0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Steps
            Expanded(
              flex: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FootprintsIcon(
                    size: 20,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      record.formattedSteps,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Time
            Expanded(
              flex: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.clock,
                    size: 17,
                    color: Color(0xFFFF9500),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      record.formattedTime,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Calories
            Expanded(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.flame,
                    size: 17,
                    color: Color(0xFFFF4B4B),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${record.calories}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Distance
            Expanded(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    size: 17,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      record.distanceKm.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
