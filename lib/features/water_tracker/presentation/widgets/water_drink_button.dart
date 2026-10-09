import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// "Drink" capsule that morphs into an outlined "Drinking..." state (design
/// 48) while the water level rises. Presses shrink slightly for feedback.
class WaterDrinkButton extends StatefulWidget {
  final bool isDrinking;
  final VoidCallback onPressed;

  const WaterDrinkButton({
    super.key,
    required this.isDrinking,
    required this.onPressed,
  });

  @override
  State<WaterDrinkButton> createState() => _WaterDrinkButtonState();
}

class _WaterDrinkButtonState extends State<WaterDrinkButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: SizedBox(
        width: 165,
        height: 52,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: widget.isDrinking ? _drinking() : _drink(),
        ),
      ),
    );
  }

  Widget _drink() {
    return Listener(
      key: const ValueKey('drink'),
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: SizedBox.expand(
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: const Text(
            'Drink',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _drinking() {
    return SizedBox.expand(
      key: const ValueKey('drinking'),
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: AppColors.primaryPurple,
          side: const BorderSide(color: AppColors.primaryPurple, width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Text(
          'Drinking...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
