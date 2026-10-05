import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// How the user chooses to create their account.
enum SignUpMethod { phone, email }

/// Pill-shaped Phone / Email switch with a sliding purple highlight.
class SignUpMethodToggle extends StatelessWidget {
  final SignUpMethod method;
  final ValueChanged<SignUpMethod> onChanged;

  const SignUpMethodToggle({
    super.key,
    required this.method,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const height = 48.0;
    final isPhone = method == SignUpMethod.phone;

    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(height),
      ),
      child: Stack(
        children: [
          // Sliding highlight
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: isPhone ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _Segment(
                  key: const Key('signup_method_phone'),
                  label: 'Phone',
                  selected: isPhone,
                  onTap: () => onChanged(SignUpMethod.phone),
                ),
              ),
              Expanded(
                child: _Segment(
                  key: const Key('signup_method_email'),
                  label: 'Email',
                  selected: !isPhone,
                  onTap: () => onChanged(SignUpMethod.email),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
