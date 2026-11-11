import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/screens/forgot_password_screen.dart';

class AccountSecurityScreen extends StatelessWidget {
  final UserModel? user;

  const AccountSecurityScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final email = user?.email.isNotEmpty == true
        ? user!.email
        : 'Not available';

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Account & Security',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Account details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: LucideIcons.mail,
            label: 'Email address',
            value: email,
            palette: p,
          ),
          const SizedBox(height: 20),
          Text(
            'Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(16),
              border: p.isDark ? Border.all(color: p.divider) : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: const Icon(
                LucideIcons.lockKeyhole,
                color: AppColors.primaryPurple,
              ),
              title: Text(
                'Change password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
              subtitle: Text(
                'Reset your password securely with an email code',
                style: TextStyle(color: p.textSecondary),
              ),
              trailing: Icon(Icons.chevron_right, color: p.textSecondary),
              onTap: () => Navigator.of(context).push(
                AppPageRoute(page: ForgotPasswordScreen(initialEmail: email)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Keep your account information private and use a strong password that you do not reuse elsewhere.',
            style: TextStyle(fontSize: 13, height: 1.4, color: p.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppPalette palette;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: palette.isDark ? Border.all(color: palette.divider) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryPurple),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
