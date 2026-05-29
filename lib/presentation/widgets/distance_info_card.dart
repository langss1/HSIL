import 'package:flutter/material.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';

/// Card displaying GPS distance information, accuracy, and last update time.
class DistanceInfoCard extends StatelessWidget {
  const DistanceInfoCard({
    super.key,
    required this.distanceMeters,
    required this.isInArea,
    this.accuracy,
    this.lastUpdated,
    this.officeName = 'HSIL Main Plant',
  });

  /// Distance from office in meters.
  final double distanceMeters;

  /// Whether the user is within geofence.
  final bool isInArea;

  /// GPS accuracy in meters.
  final double? accuracy;

  /// Timestamp of the last GPS update.
  final DateTime? lastUpdated;

  /// Display name of the office.
  final String officeName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.deepNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.safetyOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.safetyOrange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      officeName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.deepNavy,
                          ),
                    ),
                    Text(
                      'Radius: 500m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Divider
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.deepNavy.withValues(alpha: 0.06),
          ),
          const SizedBox(height: Spacing.md),

          // Info rows
          _InfoRow(
            icon: Icons.straighten_rounded,
            label: 'Jarak',
            value: '${distanceMeters.toStringAsFixed(1)}m',
            valueColor: isInArea ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: Spacing.sm),
          if (accuracy != null) ...[
            _InfoRow(
              icon: Icons.gps_fixed_rounded,
              label: 'Akurasi GPS',
              value: '±${accuracy!.toStringAsFixed(0)}m',
              valueColor: accuracy! <= 20
                  ? AppColors.success
                  : accuracy! <= 50
                      ? AppColors.warning
                      : AppColors.error,
            ),
            const SizedBox(height: Spacing.sm),
          ],
          if (lastUpdated != null)
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: 'Update terakhir',
              value: _formatTime(lastUpdated!),
              valueColor: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
