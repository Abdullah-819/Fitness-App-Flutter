import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../onboarding/presentation/screens/welcome_screen.dart';
import '../../data/auth_service.dart';
import '../widgets/auth_form_icons.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/phone_number_field.dart';
import '../widgets/sign_up_method_toggle.dart';
import '../widgets/sign_in_loading_dialog.dart';
import 'forgot_password_screen.dart';

/// Pixel-accurate Sign In Screen matching design 16_Light_sign in blank form.png.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  SignUpMethod _method = SignUpMethod.phone;

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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Displays modal bottom sheet to pick from the 3 team members
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
                  'Select Team Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap any member to auto-fill credentials & sign in directly.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
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
                        '${member.role} • pass: ${member.password}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.login_rounded,
                        size: 20,
                        color: AppColors.primaryPurple,
                      ),
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _selectMemberAndSignIn(member);
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

  /// Alias for backward compatibility and AppBar options
  void _fillDefaultUser() {
    _showTeamMemberPicker();
  }

  /// Automatically fills selected member credentials and triggers sign-in
  void _selectMemberAndSignIn(TeamMemberCredentials member) {
    setState(() {
      _method = SignUpMethod.email;
      _emailController.text = member.email;
      _passwordController.text = member.password;
      _rememberMe = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Logging in as ${member.name}...',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
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

    // Automatically execute sign-in
    _handleSignIn();
  }

  /// Executes sign-in with loading modal matching 18_Light_sign in loading.png
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(
        _method == SignUpMethod.phone
            ? 'Please enter a valid phone number and password'
            : 'Please enter valid email and password',
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Show loading modal with purple rotating spinner
    SignInLoadingDialog.show(context, message: 'Sign in...');

    try {
      final user = _method == SignUpMethod.phone
          ? await AuthService.instance.signInWithPhone(
              phone: PkPhone.e164(_phoneController.text),
              password: _passwordController.text,
            )
          : await AuthService.instance.signIn(
              email: _emailController.text,
              password: _passwordController.text,
            );

      if (!mounted) return;

      // Dismiss loading modal
      SignInLoadingDialog.hide(context);

      // Green success toast message at the bottom
      AppToast.success('Welcome back, ${user.name}!');

      // Navigate to Home with smooth fade transition
      Navigator.of(context)
          .pushReplacement(AppPageRoute.fade(page: HomeScreen(user: user)));
    } catch (e) {
      if (!mounted) return;

      // Dismiss loading modal
      SignInLoadingDialog.hide(context);

      // Clean error message
      final errorMsg = e
          .toString()
          .replaceFirst('AuthException: ', '')
          .replaceFirst('Exception: ', '');

      // Red custom error toast at the bottom
      AppToast.error(errorMsg);

      // Also show user-friendly SnackBar with Fill Default action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMsg,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
              Navigator.of(
                context,
              ).pushReplacement(AppPageRoute.fade(page: const WelcomeScreen()));
            }
          },
        ),
        actions: [
          if (AppConfig.isStaging)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
              tooltip: 'Options',
              onSelected: (value) {
                if (value == 'fill') {
                  _fillDefaultUser();
                } else if (value == 'help') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Help: Use andrew.ainsley@yourdomain.com / password123',
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'fill',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppColors.primaryPurple,
                      ),
                      SizedBox(width: 10),
                      Text('Auto-fill Demo User'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'help',
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
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

                      // Helper banner to select team account (staging only)
                      if (AppConfig.isStaging)
                        GestureDetector(
                          onTap: _showTeamMemberPicker,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryPurple.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  LucideIcons.users,
                                  size: 18,
                                  color: AppColors.primaryPurple,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Tap to auto-fill team credentials (Abdullah Rana, Ahmad Ali, Abdullah Qureshi)',
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

                      // Phone / Email switch
                      SignUpMethodToggle(
                        method: _method,
                        onChanged: (m) {
                          if (m == _method) return;
                          FocusScope.of(context).unfocus();
                          setState(() => _method = m);
                        },
                      ),

                      const SizedBox(height: 22),

                      // Phone or email input, cross-faded when switching
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _method == SignUpMethod.phone
                              ? KeyedSubtree(
                                  key: const ValueKey('phone_input'),
                                  child: PhoneNumberField(
                                    controller: _phoneController,
                                  ),
                                )
                              : KeyedSubtree(
                                  key: const ValueKey('email_input'),
                                  child: CustomTextField(
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your email address';
                                      }
                                      if (!value.contains('@') ||
                                          !value.contains('.')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Password Input Field (with left Lucide lock icon & right Lucide eye toggle)
                      CustomTextField(
                        label: 'Password',
                        hintText: 'Password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSignIn(),
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
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
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

                      const SizedBox(height: 18),

                      // Remember me & Forgot Password Row (equal flex, aligned height & padding)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                  vertical: 6,
                                  horizontal: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      curve: Curves.easeInOut,
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? AppColors.primaryPurple
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _rememberMe
                                              ? AppColors.primaryPurple
                                              : const Color(0xFFD1D5DB),
                                          width: 1.8,
                                        ),
                                        boxShadow: _rememberMe
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
                                      child: _rememberMe
                                          ? const Center(
                                              child: Icon(
                                                LucideIcons.check,
                                                size: 13,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 9),
                                    const Flexible(
                                      child: Text(
                                        'Remember me',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.1,
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
                            key: const Key('forgot_password_button'),
                            onPressed: () {
                              if (AppConfig.isProduction) {
                                AppToast.info(
                                  'Password reset is not available yet.',
                                );
                                return;
                              }
                              if (_method == SignUpMethod.phone) {
                                AppToast.info(
                                  'Password reset by phone is not available yet. '
                                  'Switch to Email to reset your password.',
                                );
                                return;
                              }
                              Navigator.of(context).push(
                                AppPageRoute(
                                  page: ForgotPasswordScreen(
                                    initialEmail: _emailController.text.trim(),
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryPurple,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Sign In button (right below the Remember me row)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          key: const Key('sign_in_button'),
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
          ],
        ),
      ),
    );
  }
}
