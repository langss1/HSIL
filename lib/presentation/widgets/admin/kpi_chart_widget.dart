import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/themes/color_palette.dart';

class AttendancePieChart extends StatelessWidget {
  final int hadir;
  final int telat;
  final int alpha;
  final int izin;

  const AttendancePieChart({
    super.key,
    required this.hadir,
    required this.telat,
    required this.alpha,
    required this.izin,
  });

  @override
  Widget build(BuildContext context) {
    final total = hadir + telat + alpha + izin;
    if (total == 0) {
      return const Center(
        child: Text(
          'Tidak ada data untuk ditampilkan',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            if (hadir > 0)
              PieChartSectionData(
                color: AppColors.statusHadir,
                value: hadir.toDouble(),
                title: '${((hadir / total) * 100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (telat > 0)
              PieChartSectionData(
                color: AppColors.statusTelat,
                value: telat.toDouble(),
                title: '${((telat / total) * 100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (alpha > 0)
              PieChartSectionData(
                color: AppColors.statusAlpha,
                value: alpha.toDouble(),
                title: '${((alpha / total) * 100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (izin > 0)
              PieChartSectionData(
                color: AppColors.statusIzin,
                value: izin.toDouble(),
                title: '${((izin / total) * 100).toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
