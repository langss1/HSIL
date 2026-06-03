import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/color_palette.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/kpi_chart_widget.dart';

class KpiDashboardScreen extends StatefulWidget {
  const KpiDashboardScreen({super.key});

  @override
  State<KpiDashboardScreen> createState() => _KpiDashboardScreenState();
}

class _KpiDashboardScreenState extends State<KpiDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();

    // Calculate Izin (we don't track it explicitly in today's simple stats, but we can mock it or calculate it)
    // For now, let's just use what's available
    int totalHadir = adminProv.todayTotalAttendance;
    int totalTelat = adminProv.todayLates;
    int totalAlpha = adminProv.todayAbsents;
    int totalIzin = 0; // Placeholder until Izin feature is fully built

    return Scaffold(
      backgroundColor: AppColors.bgDarker,
      appBar: AppBar(
        title: const Text('Grafik KPI Hari Ini'),
        backgroundColor: AppColors.bgDarker,
        elevation: 0,
      ),
      body: adminProv.isLoading && adminProv.todayAttendance.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribusi Kehadiran',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bgCardLight),
                    ),
                    child: Column(
                      children: [
                        AttendancePieChart(
                          hadir: totalHadir,
                          telat: totalTelat,
                          alpha: totalAlpha,
                          izin: totalIzin,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Legend(color: AppColors.statusHadir, label: 'Hadir ($totalHadir)'),
                            _Legend(color: AppColors.statusTelat, label: 'Telat ($totalTelat)'),
                            _Legend(color: AppColors.statusAlpha, label: 'Alpha ($totalAlpha)'),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Placeholder for Weekly or Monthly trends
                  Text(
                    'Analisis Lanjutan (Coming Soon)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bgCardLight.withOpacity(0.5)),
                    ),
                    child: const Center(
                      child: Text(
                        'Grafik Trend Mingguan/Bulanan akan muncul di sini',
                        style: TextStyle(color: AppColors.textTertiary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
