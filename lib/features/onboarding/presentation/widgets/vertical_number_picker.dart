import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Interactive, physics-based vertical number wheel picker matching
/// designs 12_Light_sign up step 3, 13_Light_sign up step 4,
/// 14_Light_sign up step 5, and 15_Light_sign up step 6.
class VerticalNumberPicker extends StatefulWidget {
  final List<int> values;
  final int initialValue;
  final String unit;
  final ValueChanged<int> onChanged;
  final double itemExtent;
  final double height;

  const VerticalNumberPicker({
    super.key,
    required this.values,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
    this.itemExtent = 52.0,
    this.height = 320.0,
  });

  @override
  State<VerticalNumberPicker> createState() => _VerticalNumberPickerState();
}

class _VerticalNumberPickerState extends State<VerticalNumberPicker> {
  late FixedExtentScrollController _scrollController;
  late int _selectedIndex;
  bool _isProgrammaticJump = false;

  @override
  void initState() {
    super.initState();
    final index = widget.values.indexOf(widget.initialValue);
    _selectedIndex = index != -1 ? index : (widget.values.length ~/ 2);
    _scrollController = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void didUpdateWidget(VerticalNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue || widget.values != oldWidget.values) {
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

  void _onItemTapped(int index) {
    _scrollController.animateToItem(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
    setState(() {
      _selectedIndex = index;
    });
    widget.onChanged(widget.values[index]);
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
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: widget.itemExtent,
            perspective: 0.003,
            diameterRatio: 3.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              if (_isProgrammaticJump) return;
              if (index >= 0 && index < widget.values.length && index != _selectedIndex) {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onChanged(widget.values[index]);
              }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.values.length,
              builder: (context, index) {
                final value = widget.values[index];
                final distance = (index - _selectedIndex).abs();

                if (distance == 0) {
                  // Selected center item (large purple number + unit label)
                  return Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryPurple,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.unit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Surrounding items with smooth visual decay
                final double fontSize;
                final Color textColor;

                if (distance == 1) {
                  fontSize = 28;
                  textColor = AppColors.textPrimary;
                } else if (distance == 2) {
                  fontSize = 24;
                  textColor = const Color(0xFF6B7280);
                } else if (distance == 3) {
                  fontSize = 20;
                  textColor = const Color(0xFF9CA3AF);
                } else {
                  fontSize = 16;
                  textColor = const Color(0xFFD1D5DB);
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onItemTapped(index),
                  child: Center(
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
