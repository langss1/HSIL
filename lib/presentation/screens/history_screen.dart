import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: user?.isAdmin == true
                ? const _AdminSkeleton()
                : const _EmployeeSkeleton(),
          ),
        ),
      ),
    );
  }
}

class _EmployeeSkeleton extends StatelessWidget {
  const _EmployeeSkeleton();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    if (user == null) return const SizedBox();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusPill(
                label: 'Riwayat Absensi',
                icon: Icons.history_rounded,
                color: AppColors.info,
              ),
              const Spacer(),
              Text(
                'Bulan Ini',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.safetyOrange,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          
          FutureBuilder(
            // Fetch directly from Firestore for the history list
            // We remove orderBy to avoid the need for a composite index (failed-precondition)
            // Sorting will be done locally in Dart.
            future: FirebaseFirestore.instance
                .collection('attendance')
                .where('employeeId', isEqualTo: user.userId)
                .limit(30)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Gagal memuat data: ${snapshot.error}', style: TextStyle(color: Colors.red)));
              }

              final docs = (snapshot.data?.docs ?? []).toList();
              
              // Sort locally by clockIn date descending
              docs.sort((a, b) {
                final aTime = a.data()['clockIn'] as Timestamp?;
                final bTime = b.data()['clockIn'] as Timestamp?;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime); // Descending
              });

              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.safetyOrange.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history_toggle_off_rounded,
                            color: AppColors.safetyOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        Text(
                          'Belum Ada Riwayat Absensi',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.white
                                    : AppColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Riwayat kehadiran Anda akan tampil di sini.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 24),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final dateStr = data['date'] ?? '-';
                  final status = data['status'] ?? 'Hadir';
                  final clockIn = data['clockIn'] != null ? (data['clockIn'] as Timestamp).toDate() : null;
                  
                  final timeStr = clockIn != null 
                    ? '${clockIn.hour.toString().padLeft(2, '0')}:${clockIn.minute.toString().padLeft(2, '0')}'
                    : '--:--';

                  Color statusColor = AppColors.success;
                  if (status.toString().toLowerCase() == 'telat') statusColor = AppColors.warning;

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.fingerprint, color: statusColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jam Masuk: $timeStr',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminSkeleton extends StatelessWidget {
  const _AdminSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: AppColors.info,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Belum Ada Aktivitas Monitoring',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.white
                              : AppColors.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seluruh log absensi masuk karyawan akan terpantau di sini.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
