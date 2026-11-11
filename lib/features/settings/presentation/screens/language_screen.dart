import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/app_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  AppPreferences _preferences = const AppPreferences();

  @override
  void initState() {
    super.initState();
    PreferencesStore.instance.load().then((value) {
      if (mounted) setState(() => _preferences = value);
    });
  }

  Future<void> _selectLanguage(String language) async {
    final next = _preferences.copyWith(language: language);
    setState(() => _preferences = next);
    await PreferencesStore.instance.save(next);
  }

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
          'App Language',
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
            'Choose your language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the language used by TrackFit.',
            style: TextStyle(fontSize: 14, color: p.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(16),
              border: p.isDark ? Border.all(color: p.divider) : null,
            ),
            child: Column(
              children: [
                for (var i = 0; i < AppPreferences.languages.length; i++) ...[
                  _LanguageOption(
                    label: AppPreferences.languages[i],
                    selected:
                        _preferences.language == AppPreferences.languages[i],
                    onTap: () => _selectLanguage(AppPreferences.languages[i]),
                  ),
                  if (i < AppPreferences.languages.length - 1)
                    Divider(height: 1, color: p.divider),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              LucideIcons.languages,
              size: 22,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
            ),
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 22,
              color: selected ? AppColors.primaryPurple : p.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
