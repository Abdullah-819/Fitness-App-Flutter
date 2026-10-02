import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_palette.dart';

/// Bottom Navigation Bar matching the Dashboard Figma design (screens 25-29).
///
/// Features 5 primary app navigation destinations:
/// - Home (selected indicator with solid purple pill)
/// - Track
/// - Report
/// - History
/// - Account
class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.navBackground,
        border: Border(
          top: BorderSide(
            color: p.navBorder,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: LucideIcons.house,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTabSelected(0),
                isCustomHome: true,
              ),
              _NavItem(
                icon: LucideIcons.mapPin,
                label: 'Track',
                isSelected: currentIndex == 1,
                onTap: () => onTabSelected(1),
              ),
              _NavItem(
                icon: LucideIcons.chartColumn,
                label: 'Report',
                isSelected: currentIndex == 2,
                onTap: () => onTabSelected(2),
              ),
              _NavItem(
                icon: LucideIcons.fileText,
                label: 'History',
                isSelected: currentIndex == 3,
                onTap: () => onTabSelected(3),
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: 'Account',
                isSelected: currentIndex == 4,
                onTap: () => onTabSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCustomHome;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCustomHome = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final activeColor = p.navActive;
    final inactiveColor = p.navInactive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustomHome && isSelected)
              SizedBox(
                width: 26,
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.home_rounded, size: 28, color: activeColor),
                    Positioned(
                      bottom: 5,
                      child: Container(
                        width: 7,
                        height: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Icon(
                icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
