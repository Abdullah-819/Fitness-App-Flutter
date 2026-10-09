import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../widgets/fade_slide_in.dart';
import 'animated_int_text.dart';

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

/// Bottom sheet to pick how much water was just drunk. Returns the amount in
/// ml, or null if dismissed.
Future<int?> showAddWaterSheet(BuildContext context) {
  final p = AppPalette.of(context);
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: p.card,
    shape: _sheetShape,
    builder: (ctx) {
      const portions = [
        (150, '150 ml', Icons.local_cafe_outlined),
        (250, '250 ml', Icons.water_drop_outlined),
        (500, '500 ml', Icons.sports_bar_outlined),
      ];

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _grabHandle(p),
              const SizedBox(height: 18),
              Text(
                'Add Water Intake',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose amount to log for today',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: p.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < portions.length; i++)
                    FadeSlideIn(
                      delay: Duration(milliseconds: 80 * i),
                      duration: const Duration(milliseconds: 380),
                      offsetY: 18,
                      child: _PortionTile(
                        label: portions[i].$2,
                        icon: portions[i].$3,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(ctx).pop(portions[i].$1);
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                duration: const Duration(milliseconds: 380),
                offsetY: 18,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(250),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Quick Add +250 ml',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PortionTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PortionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_PortionTile> createState() => _PortionTileState();
}

class _PortionTileState extends State<_PortionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.primaryPurple.withValues(alpha: 0.12)
                : p.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed ? AppColors.primaryPurple : p.border,
            ),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: AppColors.primaryPurple, size: 26),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog to adjust the daily goal in 250 ml steps. Returns the new goal, or
/// null if cancelled.
Future<int?> showWaterGoalDialog(BuildContext context, int currentGoal) {
  final p = AppPalette.of(context);
  int tempGoal = currentGoal;
  bool increasing = true;

  return showDialog<int>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          void change(int delta) {
            HapticFeedback.selectionClick();
            setDialogState(() {
              increasing = delta > 0;
              tempGoal += delta;
            });
          }

          return AlertDialog(
            backgroundColor: p.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Water Goal Settings',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: p.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set your daily water intake goal:',
                  style: TextStyle(fontSize: 14, color: p.textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: tempGoal > 1000 ? () => change(-250) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primaryPurple,
                    ),
                    // The number slides up when increasing, down when decreasing.
                    SizedBox(
                      width: 120,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          final isIncoming =
                              child.key == ValueKey<int>(tempGoal);
                          final dir = increasing ? 1.0 : -1.0;
                          final offset = Tween<Offset>(
                            begin: Offset(0, isIncoming ? 0.5 * dir : -0.5 * dir),
                            end: Offset.zero,
                          ).animate(animation);
                          return ClipRect(
                            child: SlideTransition(
                              position: offset,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          '${formatMl(tempGoal)} ml',
                          key: ValueKey<int>(tempGoal),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: tempGoal < 8000 ? () => change(250) : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: TextStyle(color: p.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(tempGoal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Bottom sheet to choose the history range. Returns the chosen range.
Future<String?> showWaterRangeSheet(BuildContext context, String selected) {
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
          for (final range in const ['This Week', 'Last Week', 'This Month'])
            ListTile(
              title: Text(
                range,
                style: TextStyle(
                  fontWeight:
                      range == selected ? FontWeight.w700 : FontWeight.w500,
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
