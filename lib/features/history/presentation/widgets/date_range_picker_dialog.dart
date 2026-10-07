import 'package:flutter/material.dart';

import '../../../../widgets/animated_dropdown.dart';
import '../../data/models/report_metrics.dart';

/// Shows the animated period dropdown matching `33_Light_report - select date range.png`.
///
/// [anchorContext] must belong to the pill/button that opens the menu so the
/// panel grows out of it.
class DateRangePickerModal {
  static Future<ReportPeriodFilter?> show(
    BuildContext anchorContext, {
    required ReportPeriodFilter currentFilter,
  }) async {
    final item = await showAnimatedDropdown<ReportPeriodFilter>(
      anchorContext,
      selected: currentFilter,
      options: [
        for (final f in ReportPeriodFilter.values)
          DropdownOption(value: f, label: f.label),
      ],
    );

    if (item != ReportPeriodFilter.customRange) return item;
    if (!anchorContext.mounted) return null;

    final range = await showDateRangePicker(
      context: anchorContext,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    return range == null ? null : ReportPeriodFilter.customRange;
  }
}
