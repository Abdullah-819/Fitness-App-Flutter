import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../weight_tracker/data/weight_models.dart';

class DataAnalyticsScreen extends StatefulWidget {
  final UserModel? user;

  const DataAnalyticsScreen({super.key, this.user});

  @override
  State<DataAnalyticsScreen> createState() => _DataAnalyticsScreenState();
}

class _DataAnalyticsScreenState extends State<DataAnalyticsScreen> {
  List<WeightEntry> _entries = const [];
  double? _heightCm;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await WeightStore.instance.load();
    if (!mounted) return;
    setState(() {
      _entries = data.entries ?? const [];
      _heightCm = data.heightCm ?? widget.user?.heightCm;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final latestWeight = _entries.isNotEmpty
        ? _entries.last.kg
        : widget.user?.weightKg;
    final bmi = latestWeight != null && _heightCm != null && _heightCm! > 0
        ? calculateBmi(latestWeight, _heightCm!)
        : null;

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
          'Data & Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  Text(
                    'Your progress overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A summary based on the information you have logged.',
                    style: TextStyle(fontSize: 14, color: p.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(
                        icon: LucideIcons.scale,
                        label: 'Latest weight',
                        value: latestWeight == null
                            ? 'Not set'
                            : '${latestWeight.toStringAsFixed(1)} kg',
                        palette: p,
                      ),
                      _MetricCard(
                        icon: LucideIcons.ruler,
                        label: 'Height',
                        value: _heightCm == null
                            ? 'Not set'
                            : '${_heightCm!.round()} cm',
                        palette: p,
                      ),
                      _MetricCard(
                        icon: LucideIcons.activity,
                        label: 'BMI',
                        value: bmi == null ? 'Not set' : bmi.toStringAsFixed(1),
                        palette: p,
                      ),
                      _MetricCard(
                        icon: LucideIcons.calendarDays,
                        label: 'Weight entries',
                        value: '${_entries.length}',
                        palette: p,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: p.card,
                      borderRadius: BorderRadius.circular(16),
                      border: p.isDark ? Border.all(color: p.divider) : null,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.info,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Keep logging your measurements to make this overview more useful over time.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: p.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppPalette palette;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(16),
          border: palette.isDark ? Border.all(color: palette.divider) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: AppColors.primaryPurple),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
