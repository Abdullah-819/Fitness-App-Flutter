import 'dart:io';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../features/auth/domain/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double size;

  const UserAvatar({super.key, required this.user, required this.size});

  String get _initials {
    final parts = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = user.avatarUrl;
    final hasPhoto =
        imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primaryPurple,
      backgroundImage: hasPhoto ? FileImage(File(imagePath)) : null,
      child: hasPhoto
          ? null
          : Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
