import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/navigation/page_transitions.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../developers/presentation/screens/developers_screen.dart';
import '../../../settings/presentation/screens/personal_info_screen.dart';
import '../../../settings/presentation/screens/preferences_screen.dart';
import '../../../settings/presentation/screens/linked_accounts_screen.dart';
import '../../../settings/presentation/screens/appearance_screen.dart';
import '../../../settings/presentation/screens/language_screen.dart';
import '../../../settings/presentation/screens/faq_screen.dart';
import '../../../settings/presentation/screens/account_security_screen.dart';
import '../../../settings/presentation/screens/data_analytics_screen.dart';
import '../../../settings/presentation/screens/levels_screen.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../water_tracker/presentation/screens/water_tracker_screen.dart';
import '../../../weight_tracker/presentation/screens/weight_tracker_screen.dart';
import '../widgets/account_menu_tile.dart';
import '../../../../widgets/user_avatar.dart';

/// Body of the dashboard "Account" tab (dark theme).
///
/// Paid features (upgrade plan, payment methods, billing) are intentionally
/// not included.
class AccountView extends StatelessWidget {
  final UserModel? user;
  final int level;
  final VoidCallback onLogout;
  final ValueChanged<UserModel>? onUserUpdated;

  const AccountView({
    super.key,
    required this.user,
    required this.onLogout,
    this.level = 9,
    this.onUserUpdated,
  });

  Future<void> _openPersonalInfo(BuildContext context) async {
    final updated = await Navigator.of(context).push<UserModel>(
      AppPageRoute(
        page: PersonalInfoScreen(
          user: user ?? AuthService.instance.currentUser,
        ),
      ),
    );
    if (updated != null) {
      onUserUpdated?.call(updated);
    }
  }

  Future<void> _openPreferences(BuildContext context) async {
    final updated = await Navigator.of(context).push<UserModel>(
      AppPageRoute(
        page: PreferencesScreen(user: user ?? AuthService.instance.currentUser),
      ),
    );
    if (updated != null) {
      onUserUpdated?.call(updated);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final p = AppPalette.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: TextStyle(color: p.textPrimary)),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: p.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: TextStyle(color: p.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _LevelCard(
          level: level,
          onTap: () =>
              Navigator.of(context)
                  .push(AppPageRoute(page: LevelsScreen(level: level))),
        ),
        const SizedBox(height: 16),
        if (user != null)
          AccountSection(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: UserAvatar(user: user!, size: 52),
                title: Text(
                  user!.name.isNotEmpty ? user!.name : 'TrackFit User',
                  style: TextStyle(
                    color: AppPalette.of(context).textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  user!.email,
                  style: TextStyle(color: AppPalette.of(context).textSecondary),
                ),
                onTap: () => _openPersonalInfo(context),
              ),
            ],
          ),
        if (user != null) const SizedBox(height: 16),
        AccountSection(
          children: [
            AccountMenuTile(
              icon: LucideIcons.droplet,
              iconColor: const Color(0xFF2F9BFF),
              label: 'Water Tracker',
              onTap: () =>
                  Navigator.of(context)
                      .push(AppPageRoute(page: const WaterTrackerScreen())),
            ),
            AccountMenuTile(
              icon: LucideIcons.personStanding,
              iconColor: const Color(0xFFFF9500),
              label: 'Weight Tracker',
              onTap: () => Navigator.of(context).push(
                AppPageRoute(
                  page: WeightTrackerScreen(
                    initialWeightKg: user?.weightKg,
                    heightCm: user?.heightCm,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AccountSection(
          children: [
            AccountMenuTile(
              icon: LucideIcons.code,
              label: 'Developers',
              onTap: () =>
                  Navigator.of(context)
                      .push(AppPageRoute(page: const DevelopersScreen())),
            ),
            AccountMenuTile(
              icon: LucideIcons.settings,
              label: 'Preferences',
              onTap: () => _openPreferences(context),
            ),
            AccountMenuTile(
              icon: LucideIcons.user,
              label: 'Personal Info',
              onTap: () => _openPersonalInfo(context),
            ),
            AccountMenuTile(
              icon: LucideIcons.shieldCheck,
              label: 'Account & Security',
              onTap: () => Navigator.of(context)
                  .push(AppPageRoute(page: AccountSecurityScreen(user: user))),
            ),
            AccountMenuTile(
              icon: LucideIcons.arrowUpDown,
              label: 'Linked Accounts',
              onTap: () =>
                  Navigator.of(context)
                      .push(AppPageRoute(page: const LinkedAccountsScreen())),
            ),
            AccountMenuTile(
              icon: LucideIcons.eye,
              label: 'App Appearance',
              onTap: () =>
                  Navigator.of(context)
                      .push(AppPageRoute(page: const AppearanceScreen())),
            ),
            AccountMenuTile(
              icon: LucideIcons.languages,
              label: 'App Language',
              onTap: () =>
                  Navigator.of(context)
                      .push(AppPageRoute(page: const LanguageScreen())),
            ),
            AccountMenuTile(
              icon: LucideIcons.chartLine,
              label: 'Data & Analytics',
              onTap: () => Navigator.of(context)
                  .push(AppPageRoute(page: DataAnalyticsScreen(user: user))),
            ),
            AccountMenuTile(
              icon: LucideIcons.fileText,
              label: 'Help & Support',
              onTap: () =>
                  Navigator.of(context)
                      .push(AppPageRoute(page: const FaqScreen())),
            ),
            AccountMenuTile(
              icon: LucideIcons.logOut,
              iconColor: AppPalette.of(context).danger,
              labelColor: AppPalette.of(context).danger,
              label: 'Logout',
              showChevron: false,
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final VoidCallback onTap;

  const _LevelCard({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFC83D), Color(0xFFFF7A1A)],
                  ),
                ),
                child: Icon(LucideIcons.medal, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You are a rising star! Keep going!',
                      style: TextStyle(fontSize: 14, color: p.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(LucideIcons.chevronRight, size: 24, color: p.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
