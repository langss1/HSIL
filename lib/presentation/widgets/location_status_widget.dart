import 'package:flutter/material.dart';

import '../../core/themes/color_palette.dart';

/// Animated indicator showing whether the user is inside or outside
/// the office geofence radius.
class LocationStatusWidget extends StatelessWidget {
  const LocationStatusWidget({
    super.key,
    required this.isInArea,
    required this.distanceMeters,
    this.isLoading = false,
  });

  /// Whether the user is within the geofence.
  final bool isInArea;

  /// Distance from the office in meters.
  final double distanceMeters;

  /// Whether location data is still loading.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    final color = isInArea ? AppColors.success : AppColors.error;
    final icon = isInArea ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = isInArea ? 'Dalam Area' : 'Di Luar Area';
    final emoji = isInArea ? '🟢' : '🔴';
    final distanceText = '${distanceMeters.toStringAsFixed(0)}m';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              key: ValueKey(isInArea),
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$emoji $label',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Jarak: $distanceText dari kantor',
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Mendeteksi lokasi...',
            style: TextStyle(
              color: AppColors.info,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
