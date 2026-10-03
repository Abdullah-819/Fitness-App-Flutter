import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/local_database.dart';
import '../../../../core/services/step_session_store.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/session_store.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../goals/data/models/goal_model.dart';

/// Full-screen Personal Info management screen supporting full CRUD operations:
/// - [C] Create: Add missing personal details (phone, measurements, targets)
/// - [R] Read: Clean, structured view of personal profile, BMI & stats
/// - [U] Update: Inline & full edit mode for name, email, phone, physical metrics, goals
/// - [D] Delete: Clear individual optional attributes or reset profile data to defaults
class PersonalInfoScreen extends StatefulWidget {
  final UserModel? user;

  const PersonalInfoScreen({super.key, this.user});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late UserModel _user;
  bool _isEditing = false;
  bool _isSaving = false;

  // Controllers for editing form
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _stepGoalController;

  final _formKey = GlobalKey<FormState>();

  String _selectedGender = 'Man';
  bool _isSedentary = false;
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';

  // Preset goal chips
  static const List<int> _presetStepGoals = [4000, 6000, 8000, 10000, 12000];

  // Preset avatar icons
  static const List<({IconData icon, String label, Color color})> _avatarPresets = [
    (icon: LucideIcons.user, label: 'Standard', color: AppColors.primaryPurple),
    (icon: LucideIcons.flame, label: 'Fire', color: Color(0xFFFF5722)),
    (icon: LucideIcons.medal, label: 'Champion', color: Color(0xFFFFB300)),
    (icon: LucideIcons.heartPulse, label: 'Health', color: Color(0xFFE91E63)),
    (icon: LucideIcons.footprints, label: 'Walker', color: Color(0xFF00B0FF)),
    (icon: LucideIcons.zap, label: 'Energy', color: Color(0xFF00E676)),
  ];

  @override
  void initState() {
    super.initState();
    _user = widget.user ??
        AuthService.instance.currentUser ??
        const UserModel(
          id: 'user_default',
          email: 'user@fitness.com',
          name: 'TrackFit User',
        );

    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
    _phoneController = TextEditingController(text: _user.phone ?? '');
    _ageController = TextEditingController(
      text: _user.age != null ? _user.age.toString() : '',
    );
    _heightController = TextEditingController(
      text: _user.heightCm != null ? _user.heightCm!.round().toString() : '',
    );
    _weightController = TextEditingController(
      text: _user.weightKg != null ? _user.weightKg!.round().toString() : '',
    );
    _stepGoalController = TextEditingController(
      text: (_user.dailyStepGoal ?? 6000).toString(),
    );

    _selectedGender = _user.gender ?? 'Man';
    _isSedentary = _user.isSedentary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _stepGoalController.dispose();
    super.dispose();
  }

  void _syncControllersFromUser() {
    _nameController.text = _user.name;
    _emailController.text = _user.email;
    _phoneController.text = _user.phone ?? '';
    _ageController.text = _user.age != null ? _user.age.toString() : '';
    _heightController.text =
        _user.heightCm != null ? _user.heightCm!.round().toString() : '';
    _weightController.text =
        _user.weightKg != null ? _user.weightKg!.round().toString() : '';
    _stepGoalController.text = (_user.dailyStepGoal ?? 6000).toString();
    _selectedGender = _user.gender ?? 'Man';
    _isSedentary = _user.isSedentary ?? false;
    _heightUnit = 'cm';
    _weightUnit = 'kg';
  }

  // --- BMI Calculation ---
  double? get _bmi {
    final h = _user.heightCm;
    final w = _user.weightKg;
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    final m = h / 100.0;
    return double.parse((w / (m * m)).toStringAsFixed(1));
  }

  String get _bmiCategory {
    final bmi = _bmi;
    if (bmi == null) return 'Not set';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal Weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    final bmi = _bmi;
    if (bmi == null) return AppColors.textSecondary;
    if (bmi < 18.5) return const Color(0xFFFFB300);
    if (bmi < 25.0) return AppColors.success;
    if (bmi < 30.0) return const Color(0xFFFF7A1A);
    return AppColors.danger;
  }

  // --- CRUD: UPDATE / SAVE ---
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final parsedAge = int.tryParse(_ageController.text.trim());
      double? parsedHeight = double.tryParse(_heightController.text.trim());
      if (parsedHeight != null && _heightUnit == 'ft-in') {
        // convert inches/ft to cm if needed
        parsedHeight = parsedHeight * 2.54;
      }

      double? parsedWeight = double.tryParse(_weightController.text.trim());
      if (parsedWeight != null && _weightUnit == 'lbs') {
        parsedWeight = parsedWeight * 0.453592;
      }

      final parsedGoal =
          int.tryParse(_stepGoalController.text.trim()) ?? 6000;

      final updatedUser = _user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        gender: _selectedGender,
        isSedentary: _isSedentary,
        age: parsedAge,
        heightCm: parsedHeight,
        weightKg: parsedWeight,
        dailyStepGoal: parsedGoal > 0 ? parsedGoal : 6000,
      );

      // Persist across stores
      await AuthService.instance.updateCurrentUser(updatedUser);
      await SessionStore.instance.saveProfile(updatedUser);
      await SessionStore.instance.saveSession(updatedUser);
      await StepSessionStore.instance.saveGoal(updatedUser.dailyStepGoal ?? 6000);

      try {
        if (LocalDatabase.instance.isInitialized) {
          final box = LocalDatabase.instance.goalsBox;
          final existing = box.get('current_goal') ?? GoalModel.defaultGoal();
          await box.put(
            'current_goal',
            existing.copyWith(
              dailyStepGoal: updatedUser.dailyStepGoal ?? 6000,
              updatedAt: DateTime.now(),
            ),
          );
        }
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _user = updatedUser;
        _isEditing = false;
        _isSaving = false;
      });

      AppToast.success('Personal info updated successfully');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.error('Failed to update info: $e');
    }
  }

  // --- CRUD: DELETE / CLEAR FIELD ---
  Future<void> _deletePhone() async {
    final confirmed = await _confirmAction(
      title: 'Remove Phone Number',
      message: 'Are you sure you want to remove your phone number from your profile?',
      actionLabel: 'Remove',
      isDanger: true,
    );
    if (!confirmed) return;

    final updated = _user.copyWith(phone: null);
    await _persistUpdatedUser(updated);
    _phoneController.clear();
    AppToast.info('Phone number removed');
  }

  // --- CRUD: DELETE / RESET ALL METRICS ---
  Future<void> _resetPersonalInfo() async {
    final confirmed = await _confirmAction(
      title: 'Reset Personal Info',
      message:
          'This will remove your custom health metrics (height, weight, age, phone) '
          'and restore the daily step goal to 6,000 steps. Your account credentials will remain safe.',
      actionLabel: 'Reset Info',
      isDanger: true,
    );
    if (!confirmed) return;

    final resetUser = UserModel(
      id: _user.id,
      email: _user.email,
      name: _user.name,
      avatarUrl: null,
      phone: null,
      gender: null,
      isSedentary: null,
      age: null,
      heightCm: null,
      weightKg: null,
      dailyStepGoal: 6000,
    );

    await _persistUpdatedUser(resetUser);
    _syncControllersFromUser();
    AppToast.info('Personal information reset to defaults');
  }

  Future<void> _persistUpdatedUser(UserModel updated) async {
    setState(() => _isSaving = true);
    await AuthService.instance.updateCurrentUser(updated);
    await SessionStore.instance.saveProfile(updated);
    await SessionStore.instance.saveSession(updated);
    await StepSessionStore.instance.saveGoal(updated.dailyStepGoal ?? 6000);

    if (!mounted) return;
    setState(() {
      _user = updated;
      _isSaving = false;
    });
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String actionLabel,
    bool isDanger = false,
  }) async {
    final p = AppPalette.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: p.textPrimary)),
        content: Text(message, style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: p.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              actionLabel,
              style: TextStyle(
                color: isDanger ? p.danger : AppColors.primaryPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // --- Avatar Preset Selector ---
  void _openAvatarPicker() {
    final p = AppPalette.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Avatar Badge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: p.textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _avatarPresets.map((preset) {
                    final isSelected = _user.avatarUrl == preset.label;
                    return GestureDetector(
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final updated = _user.copyWith(avatarUrl: preset.label);
                        await _persistUpdatedUser(updated);
                        AppToast.success('Avatar updated to ${preset.label}');
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: preset.color.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryPurple
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: Icon(preset.icon, size: 28, color: preset.color),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            preset.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppColors.primaryPurple
                                  : p.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getAvatarIcon() {
    if (_user.avatarUrl != null) {
      for (final preset in _avatarPresets) {
        if (preset.label == _user.avatarUrl) return preset.icon;
      }
    }
    return LucideIcons.user;
  }

  Color _getAvatarColor() {
    if (_user.avatarUrl != null) {
      for (final preset in _avatarPresets) {
        if (preset.label == _user.avatarUrl) return preset.color;
      }
    }
    return AppColors.primaryPurple;
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Can optionally provide result
      },
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: p.textPrimary),
            onPressed: () => Navigator.of(context).pop(_user),
          ),
          title: Text(
            'Personal Info',
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            if (!_isEditing)
              IconButton(
                tooltip: 'Edit Profile',
                icon: const Icon(LucideIcons.pencil, color: AppColors.primaryPurple),
                onPressed: () {
                  _syncControllersFromUser();
                  setState(() => _isEditing = true);
                },
              )
            else
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _syncControllersFromUser();
                  });
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: p.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: _isEditing ? _buildEditForm(p) : _buildViewMode(p),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW MODE (READ, QUICK CREATE & DELETE)
  // ==========================================
  Widget _buildViewMode(AppPalette p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Avatar Header
          _buildProfileHeader(p),
          const SizedBox(height: 24),

          // Quick Health Summary (BMI, Goal, Lifestyle)
          _buildMetricsSummaryRow(p),
          const SizedBox(height: 24),

          // Section 1: Account Information (Name, Email, Phone)
          _buildInfoSection(
            p: p,
            title: 'Account Information',
            items: [
              _InfoRowData(
                icon: LucideIcons.user,
                label: 'Full Name',
                value: _user.name.isNotEmpty ? _user.name : 'TrackFit User',
              ),
              _InfoRowData(
                icon: LucideIcons.mail,
                label: 'Email',
                value: _user.email.isNotEmpty ? _user.email : 'Not set',
              ),
              _InfoRowData(
                icon: LucideIcons.phone,
                label: 'Phone',
                value: _user.phone ?? 'Not set',
                onAddTap: _user.phone == null
                    ? () {
                        _syncControllersFromUser();
                        setState(() => _isEditing = true);
                      }
                    : null,
                onDeleteTap: _user.phone != null ? _deletePhone : null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 2: Physical Metrics (Gender, Age, Height, Weight)
          _buildInfoSection(
            p: p,
            title: 'Physical Metrics',
            items: [
              _InfoRowData(
                icon: LucideIcons.userCheck,
                label: 'Gender',
                value: _user.gender ?? 'Not set',
                onAddTap: _user.gender == null
                    ? () {
                        _syncControllersFromUser();
                        setState(() => _isEditing = true);
                      }
                    : null,
              ),
              _InfoRowData(
                icon: LucideIcons.calendar,
                label: 'Age',
                value: _user.age != null ? '${_user.age} yrs' : 'Not set',
                onAddTap: _user.age == null
                    ? () {
                        _syncControllersFromUser();
                        setState(() => _isEditing = true);
                      }
                    : null,
              ),
              _InfoRowData(
                icon: LucideIcons.ruler,
                label: 'Height',
                value: _user.heightCm != null
                    ? '${_user.heightCm!.round()} cm'
                    : 'Not set',
                onAddTap: _user.heightCm == null
                    ? () {
                        _syncControllersFromUser();
                        setState(() => _isEditing = true);
                      }
                    : null,
              ),
              _InfoRowData(
                icon: LucideIcons.weight,
                label: 'Weight',
                value: _user.weightKg != null
                    ? '${_user.weightKg!.round()} kg'
                    : 'Not set',
                onAddTap: _user.weightKg == null
                    ? () {
                        _syncControllersFromUser();
                        setState(() => _isEditing = true);
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 3: Daily Target & Lifestyle
          _buildInfoSection(
            p: p,
            title: 'Daily Fitness Target',
            items: [
              _InfoRowData(
                icon: LucideIcons.footprints,
                label: 'Step Target',
                value: '${_user.dailyStepGoal ?? 6000} steps/day',
              ),
              _InfoRowData(
                icon: LucideIcons.activity,
                label: 'Lifestyle',
                value: (_user.isSedentary == true) ? 'Sedentary' : 'Active',
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Edit Profile Main Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                _syncControllersFromUser();
                setState(() => _isEditing = true);
              },
              icon: const Icon(LucideIcons.pencil, size: 18),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Delete / Reset Personal Info (D in CRUD)
          TextButton.icon(
            onPressed: _resetPersonalInfo,
            icon: Icon(LucideIcons.trash2, size: 18, color: p.danger),
            label: Text(
              'Reset Personal Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Profile Header Card with Avatar
  Widget _buildProfileHeader(AppPalette p) {
    final avatarColor = _getAvatarColor();
    final avatarIcon = _getAvatarIcon();
    final isComplete = _user.isProfileComplete;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    avatarColor.withValues(alpha: 0.8),
                    avatarColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: avatarColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(avatarIcon, size: 48, color: Colors.white),
              ),
            ),
            GestureDetector(
              onTap: _openAvatarPicker,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.background, width: 2.5),
                ),
                child: const Icon(
                  LucideIcons.camera,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          _user.name.isNotEmpty ? _user.name : 'TrackFit User',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _user.email.isNotEmpty ? _user.email : 'Personal Profile',
          style: TextStyle(
            fontSize: 14,
            color: p.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isComplete
                ? AppColors.success.withValues(alpha: 0.15)
                : const Color(0xFFFFB300).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isComplete ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
                size: 14,
                color: isComplete ? AppColors.success : const Color(0xFFFFB300),
              ),
              const SizedBox(width: 6),
              Text(
                isComplete ? 'Profile Complete' : 'Incomplete Profile',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      isComplete ? AppColors.success : const Color(0xFFFFB300),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Metrics Summary Row (BMI, Goal, Sedentary)
  Widget _buildMetricsSummaryRow(AppPalette p) {
    return Row(
      children: [
        // BMI card
        Expanded(
          child: _MetricCard(
            title: 'BMI',
            value: _bmi != null ? '$_bmi' : '--',
            subtitle: _bmiCategory,
            valueColor: _bmiColor,
            icon: LucideIcons.heartPulse,
          ),
        ),
        const SizedBox(width: 12),
        // Daily Step Goal
        Expanded(
          child: _MetricCard(
            title: 'Daily Goal',
            value: '${_user.dailyStepGoal ?? 6000}',
            subtitle: 'steps',
            valueColor: AppColors.primaryPurple,
            icon: LucideIcons.footprints,
          ),
        ),
        const SizedBox(width: 12),
        // Sedentary status
        Expanded(
          child: _MetricCard(
            title: 'Lifestyle',
            value: (_user.isSedentary == true) ? 'Sedentary' : 'Active',
            subtitle: 'activity',
            valueColor: (_user.isSedentary == true)
                ? const Color(0xFFFF7A1A)
                : const Color(0xFF00B0FF),
            icon: LucideIcons.activity,
          ),
        ),
      ],
    );
  }

  // Info Section Card Container
  Widget _buildInfoSection({
    required AppPalette p,
    required String title,
    required List<_InfoRowData> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: p.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            _buildInfoRow(p, items[i]),
            if (i < items.length - 1)
              Divider(
                color: p.divider.withValues(alpha: 0.4),
                height: 20,
                thickness: 0.8,
              ),
          ],
        ],
      ),
    );
  }

  // Info Row with optional Add or Delete actions
  Widget _buildInfoRow(AppPalette p, _InfoRowData item) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: p.background,
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 18, color: p.textSecondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 15,
              color: p.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (item.value == 'Not set' && item.onAddTap != null)
                GestureDetector(
                  onTap: item.onAddTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '+ Add',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: item.value == 'Not set'
                          ? p.textSecondary
                          : p.textPrimary,
                    ),
                  ),
                ),
              if (item.onDeleteTap != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: item.onDeleteTap,
                  child: Icon(
                    LucideIcons.trash2,
                    size: 16,
                    color: p.danger.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // EDIT MODE (FORM: UPDATE & CREATE)
  // ==========================================
  Widget _buildEditForm(AppPalette p) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Update your personal information and fitness preferences below.',
              style: TextStyle(fontSize: 14, color: p.textSecondary),
            ),
            const SizedBox(height: 24),

            // Full Name Field
            _buildInputField(
              p: p,
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameController,
              icon: LucideIcons.user,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Address Field
            _buildInputField(
              p: p,
              label: 'Email Address',
              hint: 'Enter your email',
              controller: _emailController,
              icon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email cannot be empty';
                }
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number Field
            _buildInputField(
              p: p,
              label: 'Phone Number (Optional)',
              hint: 'e.g. +923001234567',
              controller: _phoneController,
              icon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
              suffix: _phoneController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 16),
                      onPressed: () => setState(() => _phoneController.clear()),
                    )
                  : null,
            ),
            const SizedBox(height: 20),

            // Gender Selector
            Text(
              'Gender',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Man', 'Woman', 'Other'].map((g) {
                final isSelected = _selectedGender == g;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          g,
                          style: TextStyle(
                            color: isSelected ? Colors.white : p.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryPurple,
                      backgroundColor: p.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : p.border.withValues(alpha: 0.5),
                        ),
                      ),
                      showCheckmark: false,
                      onSelected: (val) {
                        if (val) setState(() => _selectedGender = g);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Age Input
            _buildInputField(
              p: p,
              label: 'Age (Years)',
              hint: 'e.g. 28',
              controller: _ageController,
              icon: LucideIcons.calendar,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final age = int.tryParse(v);
                  if (age == null || age < 10 || age > 110) {
                    return 'Please enter a valid age (10 - 110)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Height & Weight side by side with Unit Toggles
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    p: p,
                    label: 'Height ($_heightUnit)',
                    hint: _heightUnit == 'cm' ? '180' : '71',
                    controller: _heightController,
                    icon: LucideIcons.ruler,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    p: p,
                    label: 'Weight ($_weightUnit)',
                    hint: _weightUnit == 'kg' ? '75' : '165',
                    controller: _weightController,
                    icon: LucideIcons.weight,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daily Step Goal
            Text(
              'Daily Step Goal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              p: p,
              label: '',
              hint: '6000',
              controller: _stepGoalController,
              icon: LucideIcons.footprints,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final goal = int.tryParse(v ?? '');
                if (goal == null || goal < 500 || goal > 100000) {
                  return 'Goal must be between 500 and 100,000 steps';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            // Quick preset chips
            Wrap(
              spacing: 8,
              children: _presetStepGoals.map((steps) {
                final isSelected =
                    _stepGoalController.text == steps.toString();
                return ActionChip(
                  label: Text('$steps'),
                  backgroundColor: isSelected
                      ? AppColors.primaryPurple.withValues(alpha: 0.2)
                      : p.card,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryPurple
                        : p.textPrimary,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : p.border.withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    setState(() {
                      _stepGoalController.text = steps.toString();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Sedentary Lifestyle Switch Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.border.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: p.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.activity,
                      size: 20,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sedentary Lifestyle',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: p.textPrimary,
                          ),
                        ),
                        Text(
                          'Spend most of the day sitting',
                          style: TextStyle(
                            fontSize: 12,
                            color: p.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isSedentary,
                    activeTrackColor: AppColors.primaryPurple,
                    onChanged: (val) => setState(() => _isSedentary = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Changes Primary Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Input Field with Theme Awareness
  Widget _buildInputField({
    required AppPalette p,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: p.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: p.textSecondary.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: p.card,
            isDense: true,
            prefixIcon: Icon(icon, size: 20, color: p.textSecondary),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: p.border.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: p.border.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: p.danger, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onAddTap;
  final VoidCallback? onDeleteTap;

  const _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.onAddTap,
    this.onDeleteTap,
  });
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color valueColor;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: valueColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: p.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
