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
    int totalIzin = adminProv.todayLeaves;

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
    final int currentWeekday = now.weekday; // 1 = Monday, ..., 7 = Sunday
    final DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

    for (int i = 0; i < 5; i++) { // Loop 0 to 4 (Monday to Friday)
      final date = startOfWeek.add(Duration(days: i));
      final dateKey = dateFormat.format(date);
      
      final dayRecords = adminProv.weeklyAttendance.where((r) => r.date == dateKey).toList();
      final presentCount = dayRecords.where((r) => r.status == 'hadir' || r.status == 'telat').length;
      final lateCount = dayRecords.where((r) => r.status == 'telat').length;
      
      final rate = (presentCount / totalEmployees) * 100;
      
      weeklyRates.add(rate);
      weeklyLates.add(lateCount.toDouble());
      // Get short day name (Sen, Sel, Rab, Kam, Jum)
      weekDays.add(DateFormat('E', 'id_ID').format(date));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDarker : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Grafik KPI',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.deepNavy, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.deepNavy),
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
                          color: isDark ? AppColors.white : AppColors.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.bgCardLight : Colors.transparent,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                      ],
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Legend(color: AppColors.statusHadir, label: 'Hadir ($totalHadir)'),
                                const SizedBox(height: 12),
                                _Legend(color: AppColors.statusTelat, label: 'Telat ($totalTelat)'),
                              ],
                            ),
                            const SizedBox(width: 48), // Jarak antar kolom
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Legend(color: AppColors.statusAlpha, label: 'Alpha ($totalAlpha)'),
                                const SizedBox(height: 12),
                                _Legend(color: AppColors.statusIzin, label: 'Izin ($totalIzin)'),
                              ],
                            ),
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
                          color: isDark ? AppColors.white : AppColors.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.bgCardLight : Colors.transparent,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: WeeklyAttendanceChart(rates: weeklyRates, days: weekDays),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Trend Keterlambatan (Minggu Ini)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.bgCardLight : Colors.transparent,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: LateTrendChart(lates: weeklyLates, days: weekDays),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Distribusi Jam Masuk (Hari Ini)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.bgCardLight : Colors.transparent,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                      ],
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
