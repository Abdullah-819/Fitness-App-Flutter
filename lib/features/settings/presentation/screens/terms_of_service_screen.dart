import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _sections = [
    (
      title: 'Using TrackFit',
      body: 'TrackFit is a personal fitness tracking tool. Use the app responsibly and provide accurate information for the most useful results.',
    ),
    (
      title: 'Health information',
      body: 'TrackFit is not medical advice and does not replace a qualified healthcare professional. Consult a professional before making significant changes to your exercise, nutrition, or health routine.',
    ),
    (
      title: 'Your content',
      body: 'You are responsible for the profile information and tracking entries you add to the app. Keep your account information secure and up to date.',
    ),
    (
      title: 'Acceptable use',
      body: 'Do not misuse, disrupt, or attempt to gain unauthorized access to TrackFit or its services.',
    ),
    (
      title: 'Changes to these terms',
      body: 'These terms may be updated as TrackFit evolves. Continued use of the app after an update means you accept the revised terms.',
    ),
    (
      title: 'Contact',
      body: 'If you have questions about these terms, contact the TrackFit support team from Help & Support.',
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
          'Terms of Service',
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
            'Terms of Service',
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
