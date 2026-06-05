import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

    // Calculate hourly clock-in distribution from today's real database records
    final Map<int, int> hourlyData = {7: 0, 8: 0, 9: 0, 10: 0, 11: 0};
    for (final record in adminProv.todayAttendance) {
      if (record.clockIn != null) {
        final hour = record.clockIn!.toLocal().hour;
        if (hourlyData.containsKey(hour)) {
          hourlyData[hour] = hourlyData[hour]! + 1;
        } else if (hour < 7) {
          hourlyData[7] = hourlyData[7]! + 1;
        } else if (hour > 11) {
          hourlyData[11] = hourlyData[11]! + 1;
        }
      }
    }

    // Calculate weekly attendance rates and late trends for the last 7 days
    final now = DateTime.now();
    final List<double> weeklyRates = [];
    final List<double> weeklyLates = [];
    final List<String> weekDays = [];
    final totalEmployees = adminProv.employees.isEmpty ? 1 : adminProv.employees.length;

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = dateFormat.format(date);
      
      final dayRecords = adminProv.weeklyAttendance.where((r) => r.date == dateKey).toList();
      final presentCount = dayRecords.where((r) => r.status == 'hadir' || r.status == 'telat').length;
      final lateCount = dayRecords.where((r) => r.status == 'telat').length;
      
      final rate = (presentCount / totalEmployees) * 100;
      
      weeklyRates.add(rate);
      weeklyLates.add(lateCount.toDouble());
      weekDays.add(DateFormat('E', 'id_ID').format(date));
    }

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
                  Text(
                    'Tingkat Kehadiran Mingguan (%)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bgCardLight),
                    ),
                    child: WeeklyAttendanceChart(rates: weeklyRates, days: weekDays),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Trend Keterlambatan (Minggu Ini)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bgCardLight),
                    ),
                    child: LateTrendChart(lates: weeklyLates, days: weekDays),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Distribusi Jam Masuk (Hari Ini)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bgCardLight),
                    ),
                    child: HourlyDistributionChart(hourlyData: hourlyData),
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
