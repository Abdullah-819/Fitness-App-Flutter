import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/step_session_store.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../widgets/animated_dropdown.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/session_store.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../data/app_preferences.dart';
import '../widgets/preference_widgets.dart';

/// Account → Preferences (design 51). Profile values are saved to the user;
/// everything else goes to [PreferencesStore].
class PreferencesScreen extends StatefulWidget {
  final UserModel? user;

  const PreferencesScreen({super.key, this.user});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late UserModel _user;
  AppPreferences _prefs = const AppPreferences();

  static const _genders = {'Man': 'Male', 'Woman': 'Female', 'Other': 'Other'};

  @override
  void initState() {
    super.initState();
    _user =
        widget.user ??
        AuthService.instance.currentUser ??
        const UserModel(
          id: 'user_default',
          email: 'user@fitness.com',
          name: 'TrackFit User',
        );
    PreferencesStore.instance.load().then((loaded) {
      if (mounted) setState(() => _prefs = loaded);
    });
  }

  UnitSystem get _unit => _prefs.unitSystem;

  Future<void> _updatePrefs(AppPreferences next) async {
    HapticFeedback.selectionClick();
    setState(() => _prefs = next);
    await PreferencesStore.instance.save(next);
  }

  Future<void> _updateUser(UserModel next) async {
    HapticFeedback.selectionClick();
    setState(() => _user = next);
    await AuthService.instance.updateCurrentUser(next);
    await SessionStore.instance.saveSession(next);
    await StepSessionStore.instance.saveGoal(next.dailyStepGoal ?? 6000);
  }

  List<DropdownOption<int>> _range(
    int from,
    int to,
    String Function(int) label, {
    int step = 1,
  }) => [
    for (var v = from; v <= to; v += step)
      DropdownOption(value: v, label: label(v)),
  ];

  Future<void> _pickGender(BuildContext ctx) async {
    final v = await showAnimatedDropdown<String>(
      ctx,
      selected: _user.gender,
      options: [
        for (final e in _genders.entries)
          DropdownOption(value: e.key, label: e.value),
      ],
    );
    if (v != null) await _updateUser(_user.copyWith(gender: v));
  }

  Future<void> _pickAge(BuildContext ctx) async {
    final v = await showAnimatedDropdown<int>(
      ctx,
      selected: _user.age,
      options: _range(10, 110, (a) => '$a years'),
    );
    if (v != null) await _updateUser(_user.copyWith(age: v));
  }

  Future<void> _pickHeight(BuildContext ctx) async {
    final v = await showAnimatedDropdown<int>(
      ctx,
      selected: _user.heightCm?.round(),
      options: _range(100, 230, (cm) => UnitFormat.height(cm.toDouble(), _unit)),
    );
    if (v != null) await _updateUser(_user.copyWith(heightCm: v.toDouble()));
  }

  Future<void> _pickWeight(BuildContext ctx) async {
    final v = await showAnimatedDropdown<int>(
      ctx,
      selected: _user.weightKg?.round(),
      options: _range(30, 200, (kg) => UnitFormat.weight(kg.toDouble(), _unit)),
    );
    if (v != null) await _updateUser(_user.copyWith(weightKg: v.toDouble()));
  }

  Future<void> _pickUnit(BuildContext ctx) async {
    final v = await showAnimatedDropdown<UnitSystem>(
      ctx,
      selected: _unit,
      options: [
        for (final u in UnitSystem.values)
          DropdownOption(value: u, label: UnitFormat.distanceUnits(u)),
      ],
    );
    if (v != null) await _updatePrefs(_prefs.copyWith(unitSystem: v));
  }

  Future<void> _pickStepGoal(BuildContext ctx) async {
    final current = _user.dailyStepGoal ?? 6000;
    final v = await showAnimatedDropdown<int>(
      ctx,
      selected: current,
      options: _range(1000, 30000, (s) => '$s steps', step: 500),
    );
    if (v != null) await _updateUser(_user.copyWith(dailyStepGoal: v));
  }

  Future<void> _pickSensitivity(BuildContext ctx) async {
    final v = await showAnimatedDropdown<String>(
      ctx,
      selected: _prefs.sensitivity,
      options: [
        for (final s in AppPreferences.sensitivities)
          DropdownOption(value: s, label: s),
      ],
    );
    if (v != null) await _updatePrefs(_prefs.copyWith(sensitivity: v));
  }

  Future<void> _pickStepLength(BuildContext ctx) async {
    final v = await showAnimatedDropdown<int>(
      ctx,
      selected: _prefs.stepLengthCm,
      options: _range(30, 120, (cm) => UnitFormat.length(cm, _unit)),
    );
    if (v != null) await _updatePrefs(_prefs.copyWith(stepLengthCm: v));
  }

  Future<void> _pickFirstDay(BuildContext ctx) async {
    final v = await showAnimatedDropdown<String>(
      ctx,
      selected: _prefs.firstDayOfWeek,
      options: [
        for (final d in AppPreferences.weekdays)
          DropdownOption(value: d, label: d),
      ],
    );
    if (v != null) await _updatePrefs(_prefs.copyWith(firstDayOfWeek: v));
  }

  Future<void> _pickReminderTime(BuildContext ctx) async {
    final t = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay(
        hour: _prefs.reminderMinutes ~/ 60,
        minute: _prefs.reminderMinutes % 60,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t != null) {
      await _updatePrefs(
        _prefs.copyWith(reminderMinutes: t.hour * 60 + t.minute),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    const notSet = 'Not set';

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
          onPressed: () => Navigator.of(context).pop(_user),
        ),
        title: Text(
          'Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          children: [
            PreferenceCard(
              children: [
                PreferenceRow(
                  label: 'Gender',
                  value: _genders[_user.gender] ?? _user.gender ?? notSet,
                  onTap: _pickGender,
                ),
                PreferenceRow(
                  label: 'Age',
                  value: _user.age == null ? notSet : '${_user.age} years',
                  onTap: _pickAge,
                ),
                PreferenceRow(
                  label: 'Height',
                  value: _user.heightCm == null
                      ? notSet
                      : UnitFormat.height(_user.heightCm!, _unit),
                  onTap: _pickHeight,
                ),
                PreferenceRow(
                  label: 'Weight',
                  value: _user.weightKg == null
                      ? notSet
                      : UnitFormat.weight(_user.weightKg!, _unit),
                  onTap: _pickWeight,
                ),
              ],
            ),
            const SizedBox(height: 16),
            PreferenceCard(
              children: [
                PreferenceRow(
                  label: 'Unit',
                  value: UnitFormat.distanceUnits(_unit),
                  onTap: _pickUnit,
                ),
                PreferenceRow(
                  label: 'Step Goal',
                  value: '${_user.dailyStepGoal ?? 6000} steps',
                  onTap: _pickStepGoal,
                ),
                PreferenceRow(
                  label: 'Sensitivity',
                  value: _prefs.sensitivity,
                  onTap: _pickSensitivity,
                ),
                PreferenceRow(
                  label: 'Step Length',
                  value: UnitFormat.length(_prefs.stepLengthCm, _unit),
                  onTap: _pickStepLength,
                ),
                PreferenceRow(
                  label: 'First Day of Week',
                  value: _prefs.firstDayOfWeek,
                  onTap: _pickFirstDay,
                ),
              ],
            ),
            const SizedBox(height: 16),
            PreferenceCard(
              children: [
                PreferenceSwitchRow(
                  label: 'Daily Step Reminder',
                  value: _prefs.reminderEnabled,
                  onChanged: (v) =>
                      _updatePrefs(_prefs.copyWith(reminderEnabled: v)),
                ),
                const PreferenceDivider(),
                PreferenceRow(
                  label: 'Reminder Time',
                  value: UnitFormat.time(_prefs.reminderMinutes),
                  onTap: _pickReminderTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
