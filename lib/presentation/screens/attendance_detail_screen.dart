import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../../domain/entities/attendance_record.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key, required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    DateTime date = DateTime.tryParse(record.date) ?? DateTime.now();

    Color statusColor = AppColors.statusHadir;
    final s = record.status.toLowerCase();
    if (s == 'telat') statusColor = AppColors.statusTelat;
    if (s == 'izin') statusColor = AppColors.statusIzin;
    if (s == 'alpha') statusColor = AppColors.statusAlpha;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: const Text('Detail Kehadiran'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(dateFormat.format(date), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: Spacing.md),
            StatusPill(label: record.status.toUpperCase(), color: statusColor, icon: Icons.verified),
            const SizedBox(height: Spacing.lg),
            _buildTimelineCard(context),
            const SizedBox(height: Spacing.lg),
            _buildLocationCard(context),
            const SizedBox(height: Spacing.lg),
            _buildSelfieCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    final clockInTime = record.clockIn != null ? DateFormat('HH:mm').format(record.clockIn!) : '--:--';
    final clockOutTime = record.clockOut != null ? DateFormat('HH:mm').format(record.clockOut!) : '--:--';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Waktu Presensi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: Spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeColumn('Masuk', clockInTime, Icons.login_rounded, AppColors.success),
              Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
              _buildTimeColumn('Pulang', clockOutTime, Icons.logout_rounded, AppColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, String time, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(time, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lokasi & GPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.safetyOrange),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${record.gpsStatus}'),
                    if (record.clockInDistance != null)
                      Text('Jarak: ${record.clockInDistance!.toStringAsFixed(1)} meter'),
                    if (record.clockInLat != null && record.clockInLng != null)
                      Text('Koordinat: ${record.clockInLat!.toStringAsFixed(4)}, ${record.clockInLng!.toStringAsFixed(4)}', 
                           style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelfieCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bukti Foto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: Spacing.md),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_photography_rounded, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Foto tidak tersedia', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
