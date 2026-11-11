import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/navigation/page_transitions.dart';
import 'contact_support_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _searchController = TextEditingController();

  static const _questions = [
    (
      question: 'How do I record my weight?',
      answer: 'Open Weight Tracker from the Account tab, tap Add weight, enter your measurement, and save it.',
    ),
    (
      question: 'How is my BMI calculated?',
      answer: 'BMI is calculated from your current weight and height using the standard weight-in-kilograms divided by height-in-meters squared formula.',
    ),
    (
      question: 'How do I change my daily step goal?',
      answer: 'Open Preferences from Account, select Daily step goal, and choose a new target.',
    ),
    (
      question: 'Can I switch between light and dark mode?',
      answer: 'Yes. Open Account, choose App Appearance, and select the theme you prefer.',
    ),
    (
      question: 'How do I manage my water intake?',
      answer: 'Open Water Tracker from Account to add water, review today’s progress, and view your history.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final questions = _questions
        .where(
          (item) =>
              query.isEmpty ||
              item.question.toLowerCase().contains(query) ||
              item.answer.toLowerCase().contains(query),
        )
        .toList();

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
          'FAQ',
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
            'How can we help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: p.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search questions',
              hintStyle: TextStyle(color: p.textSecondary),
              prefixIcon: Icon(LucideIcons.search, color: p.textSecondary),
              filled: true,
              fillColor: p.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (questions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No matching questions found.',
                  style: TextStyle(color: p.textSecondary),
                ),
              ),
            )
          else
            ...questions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FaqTile(question: item.question, answer: item.answer),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(context)
                    .push(AppPageRoute(page: const ContactSupportScreen())),
            icon: const Icon(LucideIcons.messageCircle),
            label: const Text('Contact support'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: const BorderSide(color: AppColors.primaryPurple),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: p.isDark ? Border.all(color: p.divider) : null,
      ),
      child: ExpansionTile(
        iconColor: p.textSecondary,
        collapsedIconColor: p.textSecondary,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: p.textPrimary,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: p.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
