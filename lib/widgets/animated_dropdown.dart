import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_palette.dart';

/// One row of an [showAnimatedDropdown] menu.
class DropdownOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const DropdownOption({required this.value, required this.label, this.icon});
}

/// Opens an animated dropdown anchored under (or above, if there is no room)
/// the widget that owns [anchorContext].
///
/// The panel scales + fades out of the anchor corner and its rows slide in one
/// after another. Returns the picked value, or null if dismissed.
Future<T?> showAnimatedDropdown<T>(
  BuildContext anchorContext, {
  required List<DropdownOption<T>> options,
  T? selected,
  double minWidth = 190,
}) {
  final box = anchorContext.findRenderObject() as RenderBox;
  final overlay =
      Navigator.of(anchorContext).overlay!.context.findRenderObject()
          as RenderBox;
  final anchor = Rect.fromPoints(
    box.localToGlobal(Offset.zero, ancestor: overlay),
    box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
  );
  final palette = AppPalette.of(anchorContext);

  return showGeneralDialog<T>(
    context: anchorContext,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, _, _) => _DropdownPanel<T>(
      anchor: anchor,
      options: options,
      selected: selected,
      minWidth: minWidth,
      palette: palette,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

class _DropdownPanel<T> extends StatelessWidget {
  final Rect anchor;
  final List<DropdownOption<T>> options;
  final T? selected;
  final double minWidth;
  final AppPalette palette;

  const _DropdownPanel({
    required this.anchor,
    required this.options,
    required this.selected,
    required this.minWidth,
    required this.palette,
  });

  static const double _rowHeight = 48;
  static const double _margin = 12;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final width = math.min(
      math.max(anchor.width, minWidth),
      screen.width - _margin * 2,
    );
    final menuHeight = options.length * _rowHeight + 16;

    // Right-align to the anchor, keep fully on screen.
    final left = (anchor.right - width)
        .clamp(_margin, math.max(_margin, screen.width - width - _margin))
        .toDouble();
    final spaceBelow = screen.height - padding.bottom - anchor.bottom - _margin;
    final openUp = spaceBelow < menuHeight && anchor.top > spaceBelow;
    final maxHeight = (openUp ? anchor.top - padding.top : spaceBelow) - 8;

    final alignment = Alignment(
      anchor.right - left > width / 2 ? 1 : -1,
      openUp ? 1 : -1,
    );

    final animation = ModalRoute.of(context)!.animation!;
    final scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: left,
          top: openUp ? null : anchor.bottom + 6,
          bottom: openUp ? screen.height - anchor.top + 6 : null,
          width: width,
          child: ScaleTransition(
            scale: scale,
            alignment: alignment,
            child: Material(
              color: palette.card,
              elevation: 10,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: math.max(120, maxHeight),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final option = options[i];
                    // Rows cascade in over the second half of the animation.
                    final start = (0.15 + i * 0.06).clamp(0.0, 0.7);
                    final rowAnim = CurvedAnimation(
                      parent: animation,
                      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
                    );
                    return FadeTransition(
                      opacity: rowAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.25),
                          end: Offset.zero,
                        ).animate(rowAnim),
                        child: _OptionRow<T>(
                          option: option,
                          isSelected: option.value == selected,
                          palette: palette,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionRow<T> extends StatelessWidget {
  final DropdownOption<T> option;
  final bool isSelected;
  final AppPalette palette;

  const _OptionRow({
    required this.option,
    required this.isSelected,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(option.value),
      child: Container(
        height: _DropdownPanel._rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        color: isSelected
            ? AppColors.primaryPurple.withValues(alpha: 0.10)
            : Colors.transparent,
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 18,
                color: isSelected
                    ? AppColors.primaryPurple
                    : palette.textSecondary,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryPurple
                      : palette.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.primaryPurple,
              ),
          ],
        ),
      ),
    );
  }
}
