import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

/// Clean, modern Lucide-based Mail icon for Email input field.
class AuthMailIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AuthMailIcon({
    super.key,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      LucideIcons.mail,
      size: size,
      color: color ?? IconTheme.of(context).color ?? AppColors.textLight,
    );
  }
}

/// Clean, modern Lucide-based Lock icon for Password input field.
class AuthLockIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AuthLockIcon({
    super.key,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      LucideIcons.lock,
      size: size,
      color: color ?? IconTheme.of(context).color ?? AppColors.textLight,
    );
  }
}

/// Clean, modern Lucide-based Eye / EyeOff icon for Password toggle.
class AuthEyeIcon extends StatelessWidget {
  final bool isObscured;
  final double size;
  final Color? color;

  const AuthEyeIcon({
    super.key,
    required this.isObscured,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      isObscured ? LucideIcons.eyeOff : LucideIcons.eye,
      size: size,
      color: color ?? IconTheme.of(context).color ?? AppColors.textLight,
    );
  }
}
