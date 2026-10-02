import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

/// Password strength rules shown under the sign-up password field.
class PasswordRules {
  PasswordRules._();

  static const List<({String label, bool Function(String) test})> rules = [
    (label: 'Must be of 8 characters', test: _hasMinLength),
    (label: 'At least 1 number e.g. 123', test: _hasNumber),
    (label: 'At least 1 special character e.g. @, #', test: _hasSpecial),
    (label: '1 uppercase alphabet e.g. ABC', test: _hasUppercase),
  ];

  static bool _hasMinLength(String p) => p.length >= 8;
  static bool _hasNumber(String p) => RegExp(r'\d').hasMatch(p);
  static bool _hasSpecial(String p) =>
      RegExp(r'[^A-Za-z0-9\s]').hasMatch(p);
  static bool _hasUppercase(String p) => RegExp(r'[A-Z]').hasMatch(p);

  static bool allPassed(String password) =>
      rules.every((rule) => rule.test(password));
}

/// Live checklist: grey dot until typing starts, then red dot or green tick
/// for each rule.
class PasswordRulesChecklist extends StatelessWidget {
  final String password;

  const PasswordRulesChecklist({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final started = password.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rule in PasswordRules.rules)
          _RuleRow(
            label: rule.label,
            passed: rule.test(password),
            started: started,
          ),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String label;
  final bool passed;
  final bool started;

  const _RuleRow({
    required this.label,
    required this.passed,
    required this.started,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = passed
        ? AppColors.success
        : (started ? AppColors.danger : AppColors.textLight);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: passed
                  ? Icon(
                      LucideIcons.circleCheck,
                      key: const ValueKey('ok'),
                      size: 16,
                      color: color,
                    )
                  : Center(
                      key: const ValueKey('dot'),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}
