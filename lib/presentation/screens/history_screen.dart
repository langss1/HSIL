import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/route_constants.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../providers/history_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = context.read<AuthController>().user;
    if (user != null && user.isAdmin == false) {
      context.read<HistoryProvider>().loadMonth(employeeId: user.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: Text('Riwayat Absensi', style: TextStyle(color: isDark ? Colors.white : AppColors.deepNavy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: user?.isAdmin == true
          ? const _AdminSkeleton()
          : const _EmployeeHistory(),
    );
  }
}

class _EmployeeHistory extends StatelessWidget {
  const _EmployeeHistory();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildMonthSelector(context, provider),
        _buildSummaryCards(context, provider),
        _buildFilterChips(context, provider),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
              : provider.errorMessage != null
                  ? Center(child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)))
                  : provider.filteredRecords.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                          padding: Spacing.screenPadding,
                          itemCount: provider.filteredRecords.length,
                          separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                          itemBuilder: (context, index) {
                            final record = provider.filteredRecords[index];
                            return _HistoryCard(
                              record: record,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  RouteConstants.attendanceDetail,
                                  arguments: record,
                                );
                              },
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context, HistoryProvider provider) {
    final monthName = _HistoryScreenState._months[provider.selectedMonth - 1];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              provider.previousMonth();
              context.read<HistoryProvider>().loadMonth(
                employeeId: context.read<AuthController>().user!.userId,
              );
            },
          ),
          Text(
            '$monthName ${provider.selectedYear}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              provider.nextMonth();
              context.read<HistoryProvider>().loadMonth(
                employeeId: context.read<AuthController>().user!.userId,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, HistoryProvider provider) {
    final stats = provider.monthlyStats;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: [
          _StatBox(label: 'Hadir', count: stats['hadir'] ?? 0, color: AppColors.statusHadir),
          const SizedBox(width: Spacing.sm),
          _StatBox(label: 'Telat', count: stats['telat'] ?? 0, color: AppColors.statusTelat),
          const SizedBox(width: Spacing.sm),
          _StatBox(label: 'Izin', count: stats['izin'] ?? 0, color: AppColors.statusIzin),
          const SizedBox(width: Spacing.sm),
          _StatBox(label: 'Alpha', count: stats['alpha'] ?? 0, color: AppColors.statusAlpha),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, HistoryProvider provider) {
    final filters = ['Semua', 'Hadir', 'Telat', 'Izin', 'Alpha'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == 'Semua' 
              ? provider.filterStatus == null 
              : provider.filterStatus?.toLowerCase() == filter.toLowerCase();
          
          return Padding(
            padding: const EdgeInsets.only(right: Spacing.sm),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.setFilter(filter == 'Semua' ? null : filter);
                }
              },
              selectedColor: AppColors.safetyOrange.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.safetyOrange : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.safetyOrange : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: AppColors.safetyOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.safetyOrange),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Belum ada riwayat',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Data kehadiran bulan ini masih kosong.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record, required this.onTap});
  final dynamic record; // AttendanceRecord
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    DateTime date;
    try {
      date = DateTime.parse(record.date);
    } catch (_) {
      date = DateTime.now();
    }
    
    final clockInTime = record.clockIn != null ? DateFormat('HH:mm').format(record.clockIn!) : '--:--';
    final clockOutTime = record.clockOut != null ? DateFormat('HH:mm').format(record.clockOut!) : '--:--';

    Color statusColor = AppColors.statusHadir;
    final s = record.status.toLowerCase();
    if (s == 'telat') statusColor = AppColors.statusTelat;
    if (s == 'izin') statusColor = AppColors.statusIzin;
    if (s == 'alpha') statusColor = AppColors.statusAlpha;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.fingerprint, color: statusColor, size: 28),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.login_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(clockInTime, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(width: 12),
                    const Icon(Icons.logout_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(clockOutTime, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          StatusPill(label: record.status.toUpperCase(), color: statusColor),
        ],
      ),
    );
  }
}

class _AdminSkeleton extends StatelessWidget {
  const _AdminSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Spacing.screenPadding,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const StatusPill(
                  label: 'Admin Monitoring',
                  icon: Icons.monitor_heart_rounded,
                  color: AppColors.safetyOrange,
                ),
                const Spacer(),
                Text(
                  'Detail KPI',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.safetyOrange,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.analytics_rounded, color: AppColors.info, size: 24),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'Belum Ada Aktivitas Monitoring',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seluruh log absensi masuk karyawan akan terpantau di sini.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
