import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../data/auth_service.dart';
import '../widgets/auth_form_icons.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sign_in_loading_dialog.dart';
import 'reset_password_success_screen.dart';

/// Pixel-accurate Create New Password screen matching design 21_Light_create new password.png.
class CreateNewPasswordScreen extends StatefulWidget {
  final String email;

  const CreateNewPasswordScreen({super.key, required this.email});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSavePassword() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(
        'Please ensure passwords match and are at least 6 characters',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    SignInLoadingDialog.show(context, message: 'Updating password...');

    await Future.delayed(const Duration(milliseconds: 600));

    final newPass = _passwordController.text.trim();
    AuthService.instance.updatePassword(
      email: widget.email,
      newPassword: newPass,
    );

    if (!mounted) return;

    SignInLoadingDialog.hide(context);

    // Green success toast message at the bottom
    AppToast.success('Password updated successfully!');

    // Smooth navigation to success screen
    Navigator.of(context).pushReplacement(
      AppPageRoute(page: ResetPasswordSuccessScreen(email: widget.email)),
    );
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

                      // Title matching 21_Light_create new password.png: "Secure Your Account 🔒"
                      const Text(
                        'Secure Your Account \u{1F512}',
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
                        'Choose a new password for your TrackFit account. '
                        "Make sure it's secure and easy to remember.",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // New Password Label & Input
                      const Text(
                        'New Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'New Password',
                        hintText: 'Enter new password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
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
                            return 'Please enter a password';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Confirm New Password Label & Input
                      const Text(
                        'Confirm New Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'Confirm New Password',
                        hintText: 'Re-enter new password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSavePassword(),
                        prefixIcon: const AuthLockIcon(size: 20),
                        suffixIcon: IconButton(
                          icon: AuthEyeIcon(
                            isObscured: _obscureConfirmPassword,
                            size: 20,
                            color: _obscureConfirmPassword
                                ? AppColors.textLight
                                : AppColors.primaryPurple,
                          ),
                          splashRadius: 18,
                          tooltip: _obscureConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value.trim() != _passwordController.text.trim()) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pinned Bottom Button: "Save New Password"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  key: const Key('save_new_password_button'),
                  onPressed: _handleSavePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save New Password',
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
