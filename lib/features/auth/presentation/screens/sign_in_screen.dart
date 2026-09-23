import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../onboarding/presentation/screens/welcome_screen.dart';
import '../../data/auth_service.dart';
import '../widgets/auth_form_icons.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sign_in_loading_dialog.dart';
import '../widgets/social_logos.dart';
import '../widgets/social_sign_in_button.dart';

/// Pixel-accurate Sign In Screen matching design 16_Light_sign in blank form.png.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

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

  /// Automatically fills the default demo user credentials
  void _fillDefaultUser() {
    setState(() {
      _emailController.text = AuthService.defaultEmail;
      _passwordController.text = AuthService.defaultPassword;
      _rememberMe = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Default credentials filled (${AuthService.defaultEmail})',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

  /// Executes sign-in with loading modal matching 18_Light_sign in loading.png
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Show loading modal with purple rotating spinner
    SignInLoadingDialog.show(context, message: 'Sign in...');

    try {
      final user = await AuthService.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Dismiss loading modal
      SignInLoadingDialog.hide(context);

      // Navigate to Home / User Dashboard
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              HomeScreen(user: user),
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
          action: SnackBarAction(
            label: 'Fill Default',
            textColor: Colors.white,
            onPressed: _fillDefaultUser,
          ),
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
                _fillDefaultUser();
              } else if (value == 'help') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help: Use andrew.ainsley@yourdomain.com / password123'),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'fill',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: AppColors.primaryPurple),
                    SizedBox(width: 10),
                    Text('Auto-fill Demo User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline, size: 20, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text('Help & Support'),
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
                // Header
                const Text(
                  'Welcome Back! \u{1F44B}',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your fitness journey.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // Helper banner to easily test default user
                GestureDetector(
                  onTap: _fillDefaultUser,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 18,
                          color: AppColors.primaryPurple,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap to fill default credentials (Andrew Ainsley)',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Email Input Field (with left side mail icon & right side clear icon)
                CustomTextField(
                  label: 'Email',
                  hintText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const AuthMailIcon(
                    size: 22,
                    color: AppColors.textLight,
                  ),
                  suffixIcon: _emailController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: AppColors.textLight,
                          ),
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

                const SizedBox(height: 20),

                // Password Input Field (with left side lock icon & right side eye toggle)
                CustomTextField(
                  label: 'Password',
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignIn(),
                  prefixIcon: const AuthLockIcon(
                    size: 22,
                    color: AppColors.textLight,
                  ),
                  suffixIcon: IconButton(
                    icon: AuthEyeIcon(
                      isObscured: _obscurePassword,
                      size: 22,
                      color: AppColors.textLight,
                    ),
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
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Remember me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Remember me checkbox
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _rememberMe
                                      ? AppColors.primaryPurple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: AppColors.primaryPurple,
                                    width: 2,
                                  ),
                                ),
                                child: _rememberMe
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              const Flexible(
                                child: Text(
                                  'Remember me',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Forgot Password?
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Default user password: password123',
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

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

                const SizedBox(height: 26),

                // Social Auth Buttons with authentic logos
                SocialSignInButton(
                  icon: const GoogleLogo(size: 22),
                  label: 'Continue with Google',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sign-in clicked'),
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
                        content: Text('Apple Sign-in clicked'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                SocialSignInButton(
                  icon: const FacebookLogo(size: 22),
                  label: 'Continue with Facebook',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Facebook Sign-in clicked'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Sign In Solid Purple Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign in',
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
