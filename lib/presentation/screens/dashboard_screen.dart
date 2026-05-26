import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../widgets/animated_gradient_backdrop.dart';
import '../widgets/app_button.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_card.dart';
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

                    // ── Horizontal Employee Barcode Card (Lanyard style) ──
                    FadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.bgCard.withValues(alpha: 0.8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.safetyOrange.withValues(alpha: 0.18),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepNavy.withValues(alpha: 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Lanyard woven strap bar at the top with glowing linear animation
                            const _AnimatedLanyardStrap(),
                            // Inner card content with padding
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Avatar
                                      Container(
                                        width: 54,
                                        height: 54,
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
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.safetyOrange.withValues(alpha: 0.15),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            (user?.name.isNotEmpty == true)
                                                ? user!.name[0].toUpperCase()
                                                : 'H',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 24,
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
                                  const SizedBox(height: 16),
                                  // Thin elegant divider
                                  Container(
                                    height: 1,
                                    width: double.infinity,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : AppColors.deepNavy.withValues(alpha: 0.08),
                                  ),
                                  const SizedBox(height: 12),
                                  // Barcode Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Mock Barcode
                                      Row(
                                        children: List.generate(24, (index) {
                                          final width = (index % 3 == 0)
                                              ? 2.8
                                              : (index % 5 == 0)
                                                  ? 1.2
                                                  : 1.8;
                                          final visible = index != 4 && index != 12 && index != 18;
                                          return Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 1.0),
                                            width: width,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: visible
                                                  ? (Theme.of(context).brightness == Brightness.dark
                                                      ? Colors.white.withValues(alpha: 0.25)
                                                      : AppColors.deepNavy.withValues(alpha: 0.25))
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(0.5),
                                            ),
                                          );
                                        }),
                                      ),
                                      Text(
                                        user != null ? 'ID: ${user.nik}' : 'ID: ----------',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.white
                                      : AppColors.deepNavy,
                                ),
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.white
                          : AppColors.deepNavy,
                    ),
              ),
            ],
          ),
        ),
        // Bell Notification Button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (Theme.of(context).brightness != Brightness.dark)
                BoxShadow(
                  color: AppColors.deepNavy.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppColors.deepNavy,
            size: 22,
          ),
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepNavy,
            Color(0xFF162A45),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Celestial symbol in the background, shifted left so it peeks out next to the play button
          const Positioned(
            right: 32,
            bottom: -12,
            child: _AnimatedCelestialBackground(),
          ),
          // Content
          Padding(
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
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fingerprint_rounded,
                                color: AppColors.safetyOrange, size: 15),
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
                // Sleek Orange Play Button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.safetyOrange,
                        Color(0xFFE85A23),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.safetyOrange.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
        ],
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
        Icons.check_circle_rounded,
      ),
      (
        'Telat',
        '0',
        AppColors.warning,
        Icons.watch_later_rounded,
      ),
      (
        'Izin',
        '0',
        AppColors.info,
        Icons.event_available_rounded,
      ),
      (
        'Alpha',
        '0',
        AppColors.error,
        Icons.cancel_rounded,
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
            mainAxisSpacing: Spacing.md,
            crossAxisSpacing: Spacing.md,
            childAspectRatio: columns == 4 ? 1.45 : 1.38,
          ),
          itemBuilder: (context, index) {
            final (label, value, color, icon) = cards[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? color.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? Colors.transparent 
                        : AppColors.deepNavy.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    // Large watermark overlay icon in the background
                    Positioned(
                      bottom: -16,
                      right: -16,
                      child: Icon(
                        icon,
                        color: color.withValues(
                          alpha: isDark ? 0.08 : 0.06,
                        ),
                        size: 76,
                      ),
                    ),
                    // Accent Line (Left strip)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 16),
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
                                      color: isDark ? color : AppColors.deepNavy,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 28,
                                      height: 1,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                'Lihat semua',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.safetyOrange,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          // Beautiful Empty State Container instead of buggy skeleton loaders
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
                      color: AppColors.safetyOrange.withValues(alpha: 0.10),
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
                    'Mulai kehadiran Anda dengan mengetuk tombol di atas.',
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

// ─────────────────────── Animated Celestial Background ───────────────────────
class _AnimatedCelestialBackground extends StatefulWidget {
  const _AnimatedCelestialBackground();

  @override
  State<_AnimatedCelestialBackground> createState() =>
      __AnimatedCelestialBackgroundState();
}

class __AnimatedCelestialBackgroundState
    extends State<_AnimatedCelestialBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isDay = hour >= 5 && hour < 18.5;

    return SizedBox(
      width: 180,
      height: 180,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (isDay) {
            // Daytime: Sun at the top + multiple drifting clouds below
            final drift1 = math.sin(_controller.value * 2 * math.pi) * 14.0;
            final drift2 = math.cos(_controller.value * 2 * math.pi) * 10.0;
            final sunColor = (hour >= 11 && hour < 15)
                ? const Color(0xFFFFB300) // Siang
                : (hour < 11)
                    ? const Color(0xFFFFD54F) // Pagi
                    : const Color(0xFFFF7043); // Sore

            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. Sun at the top/center, slowly rotating, placed high
                Positioned(
                  top: 8,
                  child: Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: sunColor.withValues(alpha: 0.10),
                      size: 96,
                    ),
                  ),
                ),
                // 2. Cloud 1 drifting lower-left
                Positioned(
                  bottom: 25,
                  left: 10 + drift1,
                  child: Icon(
                    Icons.cloud_rounded,
                    color: Colors.white.withValues(alpha: 0.10),
                    size: 80,
                  ),
                ),
                // 3. Cloud 2 drifting lower-right
                Positioned(
                  bottom: 10,
                  right: 5 + drift2,
                  child: Icon(
                    Icons.cloud_rounded,
                    color: Colors.white.withValues(alpha: 0.14),
                    size: 90,
                  ),
                ),
              ],
            );
          } else {
            // Nighttime: Moon + soft cloud
            final moonPulse = 1.0 + (0.05 * math.sin(_controller.value * 2 * math.pi));
            final drift = math.sin(_controller.value * 2 * math.pi) * 8.0;

            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. Moon, slowly pulsing
                Positioned(
                  top: 25,
                  right: 35,
                  child: Transform.scale(
                    scale: moonPulse,
                    child: Icon(
                      Icons.nights_stay_rounded,
                      color: const Color(0xFFC5CAE9).withValues(alpha: 0.12),
                      size: 90,
                    ),
                  ),
                ),
                // 2. Soft drifting cloud at the bottom
                Positioned(
                  bottom: 20,
                  left: 20 + drift,
                  child: Icon(
                    Icons.cloud_rounded,
                    color: Colors.white.withValues(alpha: 0.08),
                    size: 80,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────── Animated Lanyard Strap ───────────────────────
class _AnimatedLanyardStrap extends StatefulWidget {
  const _AnimatedLanyardStrap();

  @override
  State<_AnimatedLanyardStrap> createState() => _AnimatedLanyardStrapState();
}

class _AnimatedLanyardStrapState extends State<_AnimatedLanyardStrap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              begin: Alignment(-2.0 + _controller.value * 4.0, 0.0),
              end: Alignment(0.0 + _controller.value * 4.0, 0.0),
              colors: const [
                AppColors.safetyOrange,
                AppColors.deepNavy,
                AppColors.safetyOrange,
                AppColors.deepNavy,
                AppColors.safetyOrange,
              ],
            ),
          ),
        );
      },
    );
  }
}

