import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Curved bottom navigation bar for the dashboard (powered by
/// `curved_navigation_bar`): the selected tab floats up in a purple circle
/// with a smooth animated notch.
///
/// Destinations: Home, Track, Report, History, Account.
class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<({IconData icon, String label})> _items = [
    (icon: LucideIcons.house, label: 'Home'),
    (icon: LucideIcons.mapPin, label: 'Track'),
    (icon: LucideIcons.chartColumn, label: 'Report'),
    (icon: LucideIcons.fileText, label: 'History'),
    (icon: LucideIcons.user, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return CurvedNavigationBar(
      index: currentIndex,
      height: 62,
      color: p.navBackground,
      buttonBackgroundColor: AppColors.primaryPurple,
      backgroundColor: p.background,
      animationCurve: Curves.easeOutCubic,
      animationDuration: const Duration(milliseconds: 450),
      onTap: onTabSelected,
      items: [
        for (var i = 0; i < _items.length; i++)
          Semantics(
            label: _items[i].label,
            selected: i == currentIndex,
            button: true,
            child: Icon(
              _items[i].icon,
              size: 26,
              // The selected icon sits on the purple circle.
              color: i == currentIndex ? Colors.white : p.navInactive,
            ),
          ),
      ],
    );
  }
}
