import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../splash/presentation/widgets/footprints_icon.dart';

/// Top summary card in the Report screen matching `design/History/32_Light_report.png`.
///
/// Displays:
/// - Centered twin footprint icon + large bold total step count
/// - "Total steps all the time" subtitle
/// - Horizontal dividing line
/// - Three columns: time (orange clock), calories (red flame), distance (green pin)
class ReportSummaryCard extends StatelessWidget {
  final String totalSteps;
  final String timeString;
  final String caloriesString;
  final String distanceKmString;

  const ReportSummaryCard({
    super.key,
    required this.totalSteps,
    required this.timeString,
    required this.caloriesString,
    required this.distanceKmString,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 360 ? 14 : 20,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.border.withValues(alpha: palette.isDark ? 0.3 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: palette.isDark ? 0.2 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total Steps Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FootprintsIcon(size: 26, color: AppColors.primaryPurple),
              const SizedBox(width: 10),
              Flexible(
                child: _CountUpText(
                  value: totalSteps,
                  fit: true,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Total steps all the time',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: palette.textSecondary,
            ),
          ),

          const SizedBox(height: 18),
          Divider(height: 1, thickness: 1, color: palette.divider),
          const SizedBox(height: 18),

          // Three Metrics Columns
          Row(
            children: [
              Expanded(
                child: _SummaryColumn(
                  icon: LucideIcons.clock,
                  iconColor: const Color(0xFFFF9500),
                  value: timeString,
                  label: 'time',
                ),
              ),
              Container(height: 48, width: 1, color: palette.divider),
              Expanded(
                child: _SummaryColumn(
                  icon: LucideIcons.flame,
                  iconColor: const Color(0xFFFF4B4B),
                  value: caloriesString,
                  label: 'kcal',
                ),
              ),
              Container(height: 48, width: 1, color: palette.divider),
              Expanded(
                child: _SummaryColumn(
                  icon: LucideIcons.mapPin,
                  iconColor: const Color(0xFF22C55E),
                  value: distanceKmString,
                  label: 'km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animates the numeric parts of a formatted string (e.g. "12,345", "3.4",
/// "1h 20m") from zero up to their value. Non-numeric text is kept as is.
class _CountUpText extends StatelessWidget {
  final String value;
  final TextStyle style;
  final bool fit;

  const _CountUpText({
    required this.value,
    required this.style,
    this.fit = false,
  });

  static final RegExp _number = RegExp(r'\d[\d,]*\.?\d*');

  String _format(double t) {
    return value.replaceAllMapped(_number, (m) {
      final raw = m.group(0)!;
      final target = double.tryParse(raw.replaceAll(',', ''));
      if (target == null) return raw;
      final decimals = raw.contains('.') ? raw.split('.').last.length : 0;
      final current = target * t;
      var text = current.toStringAsFixed(decimals);
      if (raw.contains(',')) {
        final parts = text.split('.');
        parts[0] = parts[0].replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
        text = parts.join('.');
      }
      return text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final text = Text(
          _format(t),
          style: style,
          maxLines: 1,
          overflow: fit ? TextOverflow.visible : TextOverflow.ellipsis,
        );
        return fit ? FittedBox(fit: BoxFit.scaleDown, child: text) : text;
      },
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _SummaryColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 8),
        _CountUpText(
          value: value,
          fit: true,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }
}
