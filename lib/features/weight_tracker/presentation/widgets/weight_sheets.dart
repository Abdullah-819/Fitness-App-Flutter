import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../onboarding/presentation/widgets/vertical_number_picker.dart';
import '../../data/weight_models.dart';

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
);

Widget _grabHandle(AppPalette p) => Center(
  child: Container(
    width: 44,
    height: 4,
    decoration: BoxDecoration(
      color: p.border,
      borderRadius: BorderRadius.circular(2),
    ),
  ),
);

/// Number-wheel sheet shared by "add weight" and "edit height".
Future<int?> _showNumberSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<int> values,
  required int initial,
  required String unit,
  required String confirmLabel,
}) {
  final p = AppPalette.of(context);
  var selected = initial;
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: p.card,
    shape: _sheetShape,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _grabHandle(p),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: p.textSecondary),
            ),
            const SizedBox(height: 12),
            VerticalNumberPicker(
              values: values,
              initialValue: initial,
              unit: unit,
              height: 240,
              onChanged: (v) => selected = v,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(ctx).pop(selected);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                confirmLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Pick today's weight in kg. Returns null if dismissed.
Future<int?> showAddWeightSheet(BuildContext context, int currentKg) =>
    _showNumberSheet(
      context,
      title: 'Log Your Weight',
      subtitle: 'Scroll to select today\'s weight',
      values: [for (var v = 30; v <= 200; v++) v],
      initial: currentKg.clamp(30, 200),
      unit: 'kg',
      confirmLabel: 'Save Weight',
    );

/// Pick height in cm for the BMI calculation. Returns null if dismissed.
Future<int?> showEditHeightSheet(BuildContext context, int currentCm) =>
    _showNumberSheet(
      context,
      title: 'Edit Your Height',
      subtitle: 'Used to calculate your BMI',
      values: [for (var v = 100; v <= 230; v++) v],
      initial: currentCm.clamp(100, 230),
      unit: 'cm',
      confirmLabel: 'Save Height',
    );

/// Choose the chart range. Returns the range label.
Future<String?> showWeightRangeSheet(BuildContext context, String selected) {
  final p = AppPalette.of(context);
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: p.card,
    shape: _sheetShape,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _grabHandle(p),
          const SizedBox(height: 12),
          for (final range in weightRanges.keys)
            ListTile(
              title: Text(
                range,
                style: TextStyle(
                  fontWeight: range == selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: range == selected
                      ? AppColors.primaryPurple
                      : p.textPrimary,
                ),
              ),
              trailing: range == selected
                  ? const Icon(Icons.check, color: AppColors.primaryPurple)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(ctx).pop(range);
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
