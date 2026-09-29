import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../data/auth_service.dart';
import '../widgets/auth_form_icons.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sign_in_loading_dialog.dart';
import 'enter_otp_screen.dart';

/// Pixel-accurate Forgot Password screen matching design 19_Light_forgot password.png.
class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.error('Please enter a valid email address');
      return;
    }

    FocusScope.of(context).unfocus();

    // Show loading modal with inkDrop spinner
    SignInLoadingDialog.show(context, message: 'Sending OTP...');

    try {
      final email = _emailController.text.trim();
      await AuthService.instance.sendPasswordResetOtp(email);

      if (!mounted) return;

      SignInLoadingDialog.hide(context);

      // Green success toast message at the bottom
      AppToast.success('OTP sent to $email! (Use demo code: 1234)');

      // Smooth transition to Enter OTP screen
      Navigator.of(context)
          .push(AppPageRoute(page: EnterOtpScreen(email: email)));
    } catch (e) {
      if (!mounted) return;

      SignInLoadingDialog.hide(context);

      final errorMsg = e
          .toString()
          .replaceFirst('AuthException: ', '')
          .replaceFirst('Exception: ', '');

      // Red error toast message at the bottom
      AppToast.error(errorMsg);
    }
  }

  void _fillDefaultUser() {
    setState(() {
      _emailController.text = AuthService.defaultEmail;
    });
    AppToast.info('Filled default demo email');
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Fill Demo Email',
            onPressed: _fillDefaultUser,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Title matching 19_Light_forgot password.png: "Forgot Your Password? 🔑"
                      const Text(
                        'Forgot Your Password? \u{1F511}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      const Text(
                        "Enter the email associated with your TrackFit account below. "
                        "We'll send you a one-time passcode (OTP) to reset your password.",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input Label: "Your Registered Email"
                      const Text(
                        'Your Registered Email',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Custom Email Input Field matching design
                      CustomTextField(
                        label: 'Email',
                        hintText: AuthService.defaultEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSendOtp(),
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
                    ],
                  ),
                ),
              ),
            ),

            // Pinned Bottom Button: "Send OTP Code"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  key: const Key('send_otp_button'),
                  onPressed: _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Send OTP Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
