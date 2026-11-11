import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_toast.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    AppToast.success('Your support request has been sent');
    _subjectController.clear();
    _messageController.clear();
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
          'Contact Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Icon(
              LucideIcons.headphones,
              size: 44,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(height: 16),
            Text(
              'We are here to help',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us what happened and our support team will get back to you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: p.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            _FieldLabel(label: 'Subject', palette: p),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectController,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: p.textPrimary),
              decoration: _decoration(p, 'What can we help with?'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter a subject'
                  : null,
            ),
            const SizedBox(height: 18),
            _FieldLabel(label: 'Message', palette: p),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              minLines: 5,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
              style: TextStyle(color: p.textPrimary),
              decoration: _decoration(p, 'Describe your issue or question'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter a message'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Send message',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(AppPalette p, String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: p.textSecondary),
    filled: true,
    fillColor: p.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryPurple),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final AppPalette palette;

  const _FieldLabel({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: palette.textPrimary,
    ),
  );
}
