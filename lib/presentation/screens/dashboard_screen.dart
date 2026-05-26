import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_button.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_card.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/status_pill.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      body: AnimatedGradientBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: Spacing.screenPadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────
                    FadeSlide(
                      child: _DashboardHeader(
                        userName: user?.name ?? 'Karyawan',
                        isAdmin: user?.isAdmin ?? false,
                        role: user?.role.value ?? '',
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),

                    // ── Quick Clock-In Card ─────────────────────
                    FadeSlide(
                      delay: const Duration(milliseconds: 80),
                      child: _ClockInCard(userName: user?.name),
                    ),
                    const SizedBox(height: Spacing.lg),

                    // ── Employee Info Card ──────────────────────
                    FadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.safetyOrange,
                                    Color(0xFFE85A23),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  (user?.name.isNotEmpty == true)
                                      ? user!.name[0].toUpperCase()
                                      : 'H',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: Spacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Memuat profil...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user == null
                                        ? 'Menyinkronkan dari Firestore...'
                                        : '${user.department} · ${user.position}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            StatusPill(
                              label: user?.role.value.toUpperCase() ?? 'SYNC',
                              icon: user?.isAdmin == true
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.engineering_rounded,
                              color: user?.isAdmin == true
                                  ? AppColors.safetyOrange
                                  : AppColors.info,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),

                    // ── Stats Grid ─────────────────────────────
                    FadeSlide(
                      delay: const Duration(milliseconds: 160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rekap Bulan Ini',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: Spacing.sm),
                          const _StatsGrid(),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),

                    // ── Skeleton Content ───────────────────────
                    FadeSlide(
                      delay: const Duration(milliseconds: 240),
                      child: user?.isAdmin == true
                          ? const _AdminSkeleton()
                          : const _EmployeeSkeleton(),
                    ),
                    const SizedBox(height: Spacing.xl),

                    // ── Logout ────────────────────────────────
                    FadeSlide(
                      delay: const Duration(milliseconds: 300),
                      child: AppButton(
                        label: 'Keluar',
                        icon: Icons.logout_rounded,
                        isOutlined: true,
                        onPressed: () =>
                            context.read<AuthController>().signOut(),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Header ───────────────────────
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.userName,
    required this.isAdmin,
    required this.role,
  });

  final String userName;
  final bool isAdmin;
  final String role;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting 👋',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        // Bell + Office badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            const StatusPill(
              label: AppConstants.officeName,
              icon: Icons.factory_rounded,
              color: AppColors.safetyOrange,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────── Clock-In Card ───────────────────────
class _ClockInCard extends StatelessWidget {
  const _ClockInCard({this.userName});
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr = _formatDate(now);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.safetyOrange,
            Color(0xFFD94F1E),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.safetyOrange.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fingerprint_rounded,
                            color: Colors.white, size: 15),
                        const SizedBox(width: 6),
                        Text(
                          'GPS + Face ID Siap',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Big Clock-In button
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.30),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ─────────────────────── Stats Grid ───────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'Hadir',
        '0',
        AppColors.success,
        Icons.check_circle_outline_rounded,
        const Color(0xFF0D4A2D)
      ),
      (
        'Telat',
        '0',
        AppColors.warning,
        Icons.schedule_rounded,
        const Color(0xFF4A3A00)
      ),
      (
        'Izin',
        '0',
        AppColors.info,
        Icons.event_available_rounded,
        const Color(0xFF0A2A5A)
      ),
      (
        'Alpha',
        '0',
        AppColors.error,
        Icons.cancel_outlined,
        const Color(0xFF4A0A0A)
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 640 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: Spacing.sm,
            crossAxisSpacing: Spacing.sm,
            childAspectRatio: columns == 4 ? 1.4 : 1.35,
          ),
          itemBuilder: (context, index) {
            final (label, value, color, icon, bgColor) = cards[index];
            return GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────── Skeletons ───────────────────────
class _EmployeeSkeleton extends StatelessWidget {
  const _EmployeeSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
                'Lihat semua',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.safetyOrange,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          const SkeletonLoader(height: 16, width: 180),
          const SizedBox(height: Spacing.sm),
          const SkeletonLoader(height: 72),
          const SizedBox(height: Spacing.sm),
          const SkeletonLoader(height: 72),
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
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          const SkeletonLoader(height: 16, width: 220),
          const SizedBox(height: Spacing.sm),
          const SkeletonLoader(height: 110),
          const SizedBox(height: Spacing.sm),
          const SkeletonLoader(height: 40, width: 160),
        ],
      ),
    );
  }
}
