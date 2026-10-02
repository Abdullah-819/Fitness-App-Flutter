import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';

/// Interactive, physics-based vertical number wheel picker matching
/// designs 12_Light_sign up step 3, 13_Light_sign up step 4,
/// 14_Light_sign up step 5, and 15_Light_sign up step 6.
///
/// Item size and colour are driven by the live scroll position, so numbers
/// grow and fade continuously while the wheel moves instead of snapping.
class VerticalNumberPicker extends StatefulWidget {
  final List<int> values;
  final int initialValue;
  final String unit;
  final ValueChanged<int> onChanged;
  final double itemExtent;
  final double height;

  /// Optional custom label for a value (e.g. inches as 5'11").
  final String Function(int value)? labelBuilder;

  const VerticalNumberPicker({
    super.key,
    required this.values,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
    this.itemExtent = 52.0,
    this.height = 320.0,
    this.labelBuilder,
  });

  @override
  State<VerticalNumberPicker> createState() => _VerticalNumberPickerState();
}

class _VerticalNumberPickerState extends State<VerticalNumberPicker> {
  static const double _maxFont = 42;
  static const double _minFont = 16;
  static const int _fadeItems = 4;

  late FixedExtentScrollController _scrollController;
  late int _selectedIndex;
  bool _isProgrammaticJump = false;

  @override
  void initState() {
    super.initState();
    final index = widget.values.indexOf(widget.initialValue);
    _selectedIndex = index != -1 ? index : (widget.values.length ~/ 2);
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndex,
    );
  }

  @override
  void didUpdateWidget(VerticalNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue ||
        widget.values != oldWidget.values) {
      final index = widget.values.indexOf(widget.initialValue);
      if (index != -1 && index != _selectedIndex) {
        _selectedIndex = index;
        _isProgrammaticJump = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpToItem(index);
          }
          _isProgrammaticJump = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _label(int value) => widget.labelBuilder?.call(value) ?? '$value';

  void _onItemTapped(int index) {
    _scrollController.animateToItem(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  /// Fractional index currently under the centre line.
  double _position() {
    if (_scrollController.hasClients) {
      return _scrollController.offset / widget.itemExtent;
    }
    return _selectedIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    const dividerWidth = 190.0;
    const dividerColor = AppColors.primaryPurple;
    final topDividerOffset = (widget.height - widget.itemExtent) / 2;
    final bottomDividerOffset = topDividerOffset + widget.itemExtent;

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Purple divider lines framing the selected middle item
          Positioned(
            top: topDividerOffset,
            child: Container(
              width: dividerWidth,
              height: 1.6,
              color: dividerColor,
            ),
          ),
          Positioned(
            top: bottomDividerOffset,
            child: Container(
              width: dividerWidth,
              height: 1.6,
              color: dividerColor,
            ),
          ),

          // Scrollable wheel
          RepaintBoundary(
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: widget.itemExtent,
              perspective: 0.003,
              diameterRatio: 3.5,
              physics: const FixedExtentScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              onSelectedItemChanged: (index) {
                if (_isProgrammaticJump) return;
                if (index >= 0 &&
                    index < widget.values.length &&
                    index != _selectedIndex) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedIndex = index);
                  widget.onChanged(widget.values[index]);
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.values.length,
                builder: (context, index) {
                  final label = _label(widget.values[index]);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onItemTapped(index),
                    child: AnimatedBuilder(
                      animation: _scrollController,
                      builder: (context, _) {
                        final distance = (index - _position()).abs();
                        return _WheelItem(
                          label: label,
                          unit: widget.unit,
                          distance: distance,
                          maxFont: _maxFont,
                          minFont: _minFont,
                          fadeItems: _fadeItems,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelItem extends StatelessWidget {
  final String label;
  final String unit;
  final double distance;
  final double maxFont;
  final double minFont;
  final int fadeItems;

  const _WheelItem({
    required this.label,
    required this.unit,
    required this.distance,
    required this.maxFont,
    required this.minFont,
    required this.fadeItems,
  });

  @override
  Widget build(BuildContext context) {
    // 1 at the centre line, falling smoothly to 0 a few items away.
    final t = (1 - distance / fadeItems).clamp(0.0, 1.0);
    final eased = Curves.easeOut.transform(t);
    // Colour reaches full purple only very close to the centre.
    final focus = (1 - distance).clamp(0.0, 1.0);

    final fontSize = minFont + (maxFont - minFont) * eased;
    final color = Color.lerp(
      Color.lerp(
        const Color(0xFFD1D5DB),
        AppColors.textPrimary,
        eased,
      ),
      AppColors.primaryPurple,
      focus,
    )!;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.lerp(
                FontWeight.w600,
                FontWeight.w800,
                focus,
              ),
              color: color,
              letterSpacing: -0.4,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (distance < 0.5) ...[
            const SizedBox(width: 8),
            Opacity(
              opacity: (1 - distance * 2).clamp(0.0, 1.0),
              child: Text(
                unit,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
