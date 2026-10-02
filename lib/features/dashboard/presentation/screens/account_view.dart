import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/app_toast.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../../core/theme/app_palette.dart';
import '../widgets/account_menu_tile.dart';
import '../widgets/appearance_sheet.dart';

/// Body of the dashboard "Account" tab (dark theme).
///
/// Paid features (upgrade plan, payment methods, billing) are intentionally
/// not included.
class AccountView extends StatelessWidget {
  final UserModel? user;
  final int level;
  final VoidCallback onLogout;

  const AccountView({
    super.key,
    required this.user,
    required this.onLogout,
    this.level = 9,
  });

  void _comingSoon(String feature) => AppToast.info('$feature coming soon');

  void _showPersonalInfo(BuildContext context) {
    final p = AppPalette.of(context);
    final u = user;
    final rows = <MapEntry<String, String>>[
      MapEntry('Name', u?.name ?? '-'),
      MapEntry('Email', u?.email ?? '-'),
      MapEntry('Gender', u?.gender ?? '-'),
      MapEntry('Age', u?.age?.toString() ?? '-'),
      MapEntry('Height', u?.heightCm != null ? '${u!.heightCm} cm' : '-'),
      MapEntry('Weight', u?.weightKg != null ? '${u!.weightKg} kg' : '-'),
      MapEntry('Daily goal',
          u?.dailyStepGoal != null ? '${u!.dailyStepGoal} steps' : '-'),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Info',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          row.key,
                          style: TextStyle(
                            fontSize: 15,
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          row.value,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final p = AppPalette.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(color: p.textPrimary),
        ),
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
            child: Text(
              'Logout',
              style: TextStyle(color: p.danger),
            ),
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
        _LevelCard(level: level, onTap: () => _comingSoon('Levels')),
        const SizedBox(height: 16),
        AccountSection(
          children: [
            AccountMenuTile(
              icon: LucideIcons.droplet,
              iconColor: const Color(0xFF2F9BFF),
              label: 'Water Tracker',
              onTap: () => _comingSoon('Water Tracker'),
            ),
            AccountMenuTile(
              icon: LucideIcons.personStanding,
              iconColor: const Color(0xFFFF9500),
              label: 'Weight Tracker',
              onTap: () => _comingSoon('Weight Tracker'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AccountSection(
          children: [
            AccountMenuTile(
              icon: LucideIcons.settings,
              label: 'Preferences',
              onTap: () => _comingSoon('Preferences'),
            ),
            AccountMenuTile(
              icon: LucideIcons.user,
              label: 'Personal Info',
              onTap: () => _showPersonalInfo(context),
            ),
            AccountMenuTile(
              icon: LucideIcons.shieldCheck,
              label: 'Account & Security',
              onTap: () => _comingSoon('Account & Security'),
            ),
            AccountMenuTile(
              icon: LucideIcons.arrowUpDown,
              label: 'Linked Accounts',
              onTap: () => _comingSoon('Linked Accounts'),
            ),
            AccountMenuTile(
              icon: LucideIcons.eye,
              label: 'App Appearance',
              onTap: () => AppearanceSheet.show(context),
            ),
            AccountMenuTile(
              icon: LucideIcons.chartLine,
              label: 'Data & Analytics',
              onTap: () => _comingSoon('Data & Analytics'),
            ),
            AccountMenuTile(
              icon: LucideIcons.fileText,
              label: 'Help & Support',
              onTap: () => _comingSoon('Help & Support'),
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
                child: Icon(
                  LucideIcons.medal,
                  size: 32,
                  color: Colors.white,
                ),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: p.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.chevronRight,
                size: 24,
                color: p.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
