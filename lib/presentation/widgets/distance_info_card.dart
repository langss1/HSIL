import 'package:flutter/material.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../../core/constants/app_constants.dart';

/// Card displaying GPS distance information, accuracy, and last update time.
class DistanceInfoCard extends StatelessWidget {
  const DistanceInfoCard({
    super.key,
    required this.distanceMeters,
    required this.isInArea,
    this.accuracy,
    this.lastUpdated,
    this.officeName = 'Telkom University',
    this.isLoading = false,
  });

  final double distanceMeters;
  final bool isInArea;
  final double? accuracy;
  final DateTime? lastUpdated;
  final String officeName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.info),
              SizedBox(height: 16),
              Text('Mendeteksi lokasi GPS...'),
            ],
          ),
        ),
      );
    }

    final statusColor = isInArea ? AppColors.success : AppColors.error;
    final statusIcon = isInArea ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final statusText = isInArea ? 'Dalam Area' : 'Di Luar Area';

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (Office & Status Badge)
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.safetyOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: AppColors.safetyOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      officeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.white : AppColors.deepNavy,
                          ),
                    ),
                    Text(
                      'Radius: 500m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.deepNavy.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 20),

          // Info Grid
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  icon: Icons.straighten_rounded,
                  label: 'Jarak GPS',
                  value: '${distanceMeters.toStringAsFixed(1)}m',
                  valueColor: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  icon: Icons.gps_fixed_rounded,
                  label: 'Akurasi',
                  value: accuracy != null ? '±${accuracy!.toStringAsFixed(0)}m' : '-',
                  valueColor: (accuracy ?? 100) <= 20
                      ? AppColors.success
                      : (accuracy ?? 100) <= 50
                          ? AppColors.warning
                          : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.deepNavy.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor ?? (isDark ? Colors.white : AppColors.deepNavy),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
          ),
        ],
      ),
    );
  }
}
