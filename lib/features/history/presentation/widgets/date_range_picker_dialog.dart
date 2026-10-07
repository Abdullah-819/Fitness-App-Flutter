import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../data/models/report_metrics.dart';

/// Shows the Date Range selection dropdown modal matching `33_Light_report - select date range.png`.
class DateRangePickerModal {
  static Future<ReportPeriodFilter?> show(
    BuildContext context, {
    required ReportPeriodFilter currentFilter,
  }) async {
    final palette = AppPalette.of(context);

    return showModalBottomSheet<ReportPeriodFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Handle bar
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // Options list matching 33_Light_report - select date range.png
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: ReportPeriodFilter.values.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: palette.divider,
                    ),
                    itemBuilder: (context, index) {
                      final item = ReportPeriodFilter.values[index];
                      final isSelected = item == currentFilter;

                      return InkWell(
                        onTap: () async {
                          if (item == ReportPeriodFilter.customRange) {
                            Navigator.of(sheetContext).pop(null);
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (range != null && context.mounted) {
                              Navigator.of(context).pop(ReportPeriodFilter.customRange);
                            }
                          } else {
                            Navigator.of(sheetContext).pop(item);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? palette.textPrimary
                                        : palette.textPrimary.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: palette.navActive,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
