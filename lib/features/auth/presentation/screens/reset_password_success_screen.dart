import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/auth_service.dart';
import '../../domain/models/user_model.dart';

/// Pixel-accurate Reset Password Successful screen matching design 22_Light_reset password successful.png.
class ResetPasswordSuccessScreen extends StatelessWidget {
  final String email;

  const ResetPasswordSuccessScreen({
    super.key,
    required this.email,
  });

  void _handleContinue(BuildContext context) {
    // Lookup user or build authenticated model
    String userName = AuthService.defaultName;
    for (final member in AuthService.teamMembers) {
      if (member.email.toLowerCase() == email.trim().toLowerCase()) {
        userName = member.name;
        break;
      }
    }

    final user = UserModel(
      id: 'user_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      email: email,
      name: userName,
    );

    AppToast.success('Welcome back, $userName!');

    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute.fade(page: HomeScreen(user: user)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Center Illustration: Purple circular badge with smartphone graphic
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primaryPurple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 104,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3E8FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.user,
                            size: 20,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Heading matching 22_Light_reset password successful.png: "You're All Set!"
            const Text(
              "You're All Set!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Your password has been successfully updated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),

            const Spacer(flex: 4),

            // Bottom Button: "Go to Homepage"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  key: const Key('go_to_homepage_button'),
                  onPressed: () => _handleContinue(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Go to Homepage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
