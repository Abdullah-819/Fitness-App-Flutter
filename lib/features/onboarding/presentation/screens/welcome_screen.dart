import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../auth/presentation/widgets/social_logos.dart';
import '../../../auth/presentation/widgets/social_sign_in_button.dart';
import '../../../splash/presentation/widgets/footprints_icon.dart';

/// Welcome / Onboarding landing screen following design 5_Light_welcome screen.png.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 36),
              // Purple Brand Icon
              Image.asset(
                AppAssets.logoPurple,
                width: 68,
                height: 68,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const FootprintsIcon(
                      size: 68,
                      color: AppColors.primaryPurple,
                    ),
              ),
              const SizedBox(height: 32),
              // Header
              const Text(
                "Let's Get Started!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E2D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's dive in into your account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 36),

              // Social Auth Buttons with authentic logos and identical alignment
              SocialSignInButton(
                icon: const GoogleLogo(size: 24),
                label: 'Continue with Google',
                onPressed: () {},
              ),
              const SizedBox(height: 14),
              SocialSignInButton(
                icon: const AppleLogo(size: 24),
                label: 'Continue with Apple',
                onPressed: () {},
              ),
              const SizedBox(height: 14),
              SocialSignInButton(
                icon: const FacebookLogo(size: 24),
                label: 'Continue with Facebook',
                onPressed: () {},
              ),
              const SizedBox(height: 14),
              SocialSignInButton(
                icon: const TwitterLogo(size: 24),
                label: 'Continue with Twitter',
                onPressed: () {},
              ),

              const SizedBox(height: 32),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3E8FF),
                    foregroundColor: AppColors.primaryPurple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Terms & Privacy
              Text(
                'Privacy Policy   ·   Terms of Service',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
