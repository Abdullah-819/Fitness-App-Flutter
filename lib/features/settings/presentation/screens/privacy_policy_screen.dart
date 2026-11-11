import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    (
      title: 'Information we collect',
      body: 'TrackFit stores the information you provide, such as your profile details, fitness goals, weight entries, water entries, and activity history.',
    ),
    (
      title: 'How we use your information',
      body: 'Your information is used to calculate progress, personalize your dashboard, and provide the tracking features you request.',
    ),
    (
      title: 'Data storage',
      body: 'Your app preferences and tracking data are stored for the app experience. You can manage or remove your entries from the related tracker screens.',
    ),
    (
      title: 'Your choices',
      body: 'You can update your profile and preferences at any time. Contact support if you have questions about your data or need assistance.',
    ),
    (
      title: 'Contact',
      body: 'For privacy questions, use the Contact Support form from the Help & Support section.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

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
          'Privacy Policy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Your privacy matters',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: November 11, 2026',
            style: TextStyle(fontSize: 13, color: p.textSecondary),
          ),
          const SizedBox(height: 20),
          for (final section in _sections) ...[
            Text(
              section.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              section.body,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: p.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
