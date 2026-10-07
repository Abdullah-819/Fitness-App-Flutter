import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../splash/presentation/widgets/footprints_icon.dart';
import '../../data/models/history_record_model.dart';
import '../../providers/history_provider.dart';
import '../widgets/history_record_tile.dart';

/// Complete History log screen implementing `design/History/34_Dark_history.png`,
/// `35_Dark_history - delete action.png`, and `36_Dark_history - deleted.png`.
class HistoryScreen extends StatelessWidget {
  final bool embeddedInDashboard;

  const HistoryScreen({
    super.key,
    this.embeddedInDashboard = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    try {
      Provider.of<HistoryProvider>(context, listen: false);
      content = const _HistoryScreenContent();
    } catch (_) {
      content = ChangeNotifierProvider<HistoryProvider>(
        create: (_) => HistoryProvider(),
        child: const _HistoryScreenContent(),
      );
    }

    if (embeddedInDashboard) {
      return content;
    }

    final palette = AppPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Center(
            child: FootprintsIcon(
              size: 28,
              color: AppColors.primaryPurple,
            ),
          ),
        ),
        title: Text(
          'History',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.ellipsisVertical,
              color: palette.textPrimary,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: content,
      ),
    );
  }
}

class _HistoryScreenContent extends StatelessWidget {
  const _HistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final history = Provider.of<HistoryProvider>(context);

    // Group records by sectionTitle
    final Map<String, List<HistoryRecordModel>> grouped = {};
    for (final record in history.historyRecords) {
      grouped.putIfAbsent(record.sectionTitle, () => []).add(record);
    }

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            for (final entry in grouped.entries) ...[
              // Section Date Header with horizontal divider line
              Row(
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: palette.divider,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Grouped records
              for (final record in entry.value)
                HistoryRecordTile(
                  record: record,
                  onDelete: () => history.deleteRecord(record),
                ),

              const SizedBox(height: 18),
            ],
          ],
        ),

        // Bottom Banner when an item is deleted (Screen 36)
        if (history.canUndoDelete)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: palette.border.withValues(alpha: palette.isDark ? 0.3 : 0.7),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.trash2,
                      color: Color(0xFFFF4B4B),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'History has been deleted',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => history.undoDelete(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Undo',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
