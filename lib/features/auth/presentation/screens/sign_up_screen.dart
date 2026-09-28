import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../onboarding/presentation/screens/sign_up_steps_screen.dart';
import '../../../onboarding/presentation/screens/welcome_screen.dart';
import '../../data/auth_service.dart';
import '../widgets/auth_form_icons.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sign_in_loading_dialog.dart';
import '../widgets/social_logos.dart';
import '../widgets/social_sign_in_button.dart';
import 'sign_in_screen.dart';

/// Pixel-accurate Sign Up Screen matching design 6_Light_sign up blank form.png,
/// 7_Light_sign up filled form.png, and 8_Light_sign up loading.png.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Displays bottom sheet with TrackFit Terms & Conditions
  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      color: AppColors.primaryPurple,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '1. Account & Security\nYour personal health metrics and step tracking information are securely stored and encrypted on your device.\n\n'
                  '2. Health & Activity\nTrackFit goals, step counts, and distance estimations are designed for general fitness motivation and personal tracking.\n\n'
                  '3. Privacy Policy\nWe strictly respect your privacy. TrackFit never shares or sells your personal activity metrics to third parties.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _agreedToTerms = true;
                      });
                      Navigator.pop(bottomSheetContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      'I Agree to Terms',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Displays modal bottom sheet to pick a demo account for quick sign up
  void _showTeamMemberPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Demo Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap any account to auto-fill credentials for quick registration.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // Default Demo User
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  color: const Color(0xFFF9FAFB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryPurple,
                      child: Text(
                        'AA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    title: const Text(
                      'Andrew Ainsley',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${AuthService.defaultEmail} • pass: ${AuthService.defaultPassword}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.person_add_rounded,
                      size: 20,
                      color: AppColors.primaryPurple,
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _fillCredentials(
                        AuthService.defaultEmail,
                        AuthService.defaultPassword,
                      );
                    },
                  ),
                ),
                // Team members
                ...AuthService.teamMembers.map((member) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    color: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryPurple,
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      title: Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${member.email} • pass: ${member.password}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.person_add_rounded,
                        size: 20,
                        color: AppColors.primaryPurple,
                      ),
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _fillCredentials(member.email, member.password);
                      },
                    ),
                  );
                }),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _agreedToTerms = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Filled credentials for $email',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Executes sign-up with loading modal matching 8_Light_sign up loading.png
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please agree to TrackFit Terms & Conditions to sign up.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Show loading modal with purple rotating spinner matching 8_Light_sign up loading.png
    SignInLoadingDialog.show(context, message: 'Sign up...');

    try {
      final user = await AuthService.instance.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Dismiss loading modal
      SignInLoadingDialog.hide(context);

      // Navigate to Sign Up Steps Onboarding (Step 1 to 6)
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SignUpStepsScreen(user: user),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Dismiss loading modal
      SignInLoadingDialog.hide(context);

      // Show user-friendly error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            }
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            tooltip: 'Options',
            onSelected: (value) {
              if (value == 'fill') {
                _showTeamMemberPicker();
              } else if (value == 'terms') {
                _showTermsAndConditions();
              } else if (value == 'signin') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'fill',
                child: Row(
                  children: [
                    Icon(Icons.person_add_outlined, size: 20, color: AppColors.primaryPurple),
                    SizedBox(width: 10),
                    Text('Auto-fill Demo User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'terms',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, size: 20, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text('Terms & Conditions'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signin',
                child: Row(
                  children: [
                    Icon(Icons.login, size: 20, color: AppColors.primaryPurple),
                    SizedBox(width: 10),
                    Text('Already have account? Sign in'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header matching 6_Light_sign up blank form.png: "Join TrackFit Today 👤"
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Join TrackFit Today',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AuthUserIcon(size: 28),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your account and start tracking your steps.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // Helper banner to select demo credentials
                GestureDetector(
                  onTap: _showTeamMemberPicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryPurple.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          LucideIcons.userPlus,
                          size: 18,
                          color: AppColors.primaryPurple,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tap to auto-fill demo or team account credentials',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronDown,
                          size: 18,
                          color: AppColors.primaryPurple,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Email Input Field (with left Lucide mail icon & right Lucide clear icon)
                CustomTextField(
                  label: 'Email',
                  hintText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const AuthMailIcon(size: 20),
                  suffixIcon: _emailController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            LucideIcons.circleX,
                            size: 18,
                            color: AppColors.textLight,
                          ),
                          splashRadius: 18,
                          tooltip: 'Clear email',
                          onPressed: () {
                            _emailController.clear();
                          },
                        )
                      : null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Password Input Field (with left Lucide lock icon & right Lucide eye toggle)
                CustomTextField(
                  label: 'Password',
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignUp(),
                  prefixIcon: const AuthLockIcon(size: 20),
                  suffixIcon: IconButton(
                    icon: AuthEyeIcon(
                      isObscured: _obscurePassword,
                      size: 20,
                      color: _obscurePassword
                          ? AppColors.textLight
                          : AppColors.primaryPurple,
                    ),
                    splashRadius: 18,
                    tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Terms & Conditions Checkbox Row matching 6_Light_sign up blank form.png
                InkWell(
                  key: const Key('terms_checkbox'),
                  onTap: () {
                    setState(() {
                      _agreedToTerms = !_agreedToTerms;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _agreedToTerms
                                ? AppColors.primaryPurple
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryPurple,
                              width: 1.8,
                            ),
                            boxShadow: _agreedToTerms
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryPurple
                                          .withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: _agreedToTerms
                              ? const Center(
                                  child: Icon(
                                    LucideIcons.check,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to TrackFit ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.1,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryPurple,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _showTermsAndConditions,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // "Already have an account? Sign in" Center Row
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider with "or"
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppColors.dividerColor,
                        thickness: 1.2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: AppColors.dividerColor,
                        thickness: 1.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Social Auth Buttons with authentic Google & Apple logos
                SocialSignInButton(
                  icon: const GoogleLogo(size: 24),
                  label: 'Continue with Google',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sign-up clicked'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                SocialSignInButton(
                  icon: const AppleLogo(size: 24),
                  label: 'Continue with Apple',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Apple Sign-up clicked'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Sign Up Solid Purple Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    key: const Key('sign_up_button'),
                    onPressed: _handleSignUp,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
