import 'package:flutter/material.dart';

import '../../../auth/domain/models/user_model.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

/// User Dashboard / Home Screen displayed after successful sign in or onboarding.
///
/// Wraps and renders [DashboardScreen] with full state and UI flows from Figma
/// designs (Screens 23 through 29).
class HomeScreen extends StatelessWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(user: user);
  }
}
