import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';

/// Helpers for Pakistani mobile numbers (+92 3XX XXXXXXX).
class PkPhone {
  PkPhone._();

  static const String dialCode = '+92';

  /// Digits only, with any +92 / 92 / leading 0 prefix removed.
  static String national(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('92') && digits.length > 10) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  /// A valid mobile number is 10 digits starting with 3 (e.g. 306 1848755).
  static bool isValid(String input) =>
      RegExp(r'^3\d{9}$').hasMatch(national(input));

  /// Canonical form used for the account, e.g. +923006789089.
  static String e164(String input) => '$dialCode${national(input)}';
}

/// Formats typed digits as `0306 1848755` (or `306 1848755` without a 0).
class _PkPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final maxDigits = digits.startsWith('0') ? 11 : 10;
    final trimmed = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;

    final firstGroup = trimmed.startsWith('0') ? 4 : 3;
    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i == firstGroup) buffer.write(' ');
      buffer.write(trimmed[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Phone number input with a Pakistan flag + `+92` prefix block.
class PhoneNumberField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  const PhoneNumberField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_isFocused != _focusNode.hasFocus) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(14));
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Phone Number *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('phone_field'),
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.phone,
          textInputAction: widget.textInputAction,
          inputFormatters: [_PkPhoneFormatter()],
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            if (!PkPhone.isValid(value)) {
              return 'Enter a valid number, e.g. 0306 1848755';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '0306 1848755',
            hintStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
            isDense: true,
            filled: true,
            fillColor: _isFocused ? Colors.white : AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
            prefixIcon: const _CountryPrefix(),
            prefixIconConstraints: const BoxConstraints(minHeight: 48),
            border: border(AppColors.stroke, 1.2),
            enabledBorder: border(AppColors.stroke, 1.2),
            focusedBorder: border(AppColors.primaryPurple, 1.8),
            errorBorder: border(AppColors.danger, 1.2),
            focusedErrorBorder: border(AppColors.danger, 1.8),
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}

class _CountryPrefix extends StatelessWidget {
  const _CountryPrefix();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          // Pakistan flag
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundSecondary,
            ),
            child: const Text(
              '\u{1F1F5}\u{1F1F0}',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            PkPhone.dialCode,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 28, color: AppColors.stroke),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
