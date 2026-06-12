import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../core/constants/route_constants.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_controller.dart';
import '../providers/notification_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/fade_slide.dart';
import '../widgets/status_pill.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<AuthController>().user;
      if (user != null) {
        context.read<AttendanceProvider>().initialize(user.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFFCFCFD),
      body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
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
                    const SizedBox(height: 16),

                    // ── Quick Clock-In Card ─────────────────────
                    FadeSlide(
                      delay: const Duration(milliseconds: 80),
                      child: _ClockInCard(userName: user?.name),
                    ),
                    const SizedBox(height: 16),

                    // ── Horizontal Employee Barcode Card (Lanyard style) ──
                    FadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Tumpukan Card di Bawah
                            Positioned(
                              top: 16,
                              left: 12,
                              right: 12,
                              bottom: -10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : const Color(0xFFE2E8F0), // Lebih terlihat
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                            // Main Card
                            Container(
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
                                  // Ajukan Izin Button
                                  AppButton(
                                    label: 'Ajukan Izin',
                                    onPressed: () => Navigator.pushNamed(context, RouteConstants.leaveRequest),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                    const SizedBox(height: 16),

                    // ── Stats Grid ─────────────────────────────
                    FadeSlide(
                      delay: const Duration(milliseconds: 160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rekap Minggu Ini',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
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
                  ],
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
    final notifProvider = context.watch<NotificationProvider>();
    
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
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, RouteConstants.notifications),
          child: Container(
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.deepNavy,
                  size: 22,
                ),
                if (notifProvider.hasUnread)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.safetyOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? const Color(0xFF1E293B) 
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
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
                    ],
                  ),
                ),
                // Sleek Orange Play Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.gpsValidation);
                  },
                  child: Container(
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
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
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
    final stats = context.watch<AttendanceProvider>().weeklyStats;
    final cards = [
      (
        'Hadir',
        stats['hadir']?.toString() ?? '0',
        AppColors.success,
        Icons.check_circle_rounded,
      ),
      (
        'Telat',
        stats['telat']?.toString() ?? '0',
        AppColors.warning,
        Icons.watch_later_rounded,
      ),
      (
        'Izin',
        stats['izin']?.toString() ?? '0',
        AppColors.info,
        Icons.event_available_rounded,
      ),
      (
        'Alpha',
        stats['alpha']?.toString() ?? '0',
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

            return FadeSlide(
              delay: Duration(milliseconds: 150 * index),
              offset: const Offset(0, 0.1),
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
              children: [
                // Tumpukan Card di Samping Kanan (Right only, no bottom offset)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 6,
                  right: -6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE2E8F0), // Grey color
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                // Main Card
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.bgCard
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.05) 
                          : AppColors.deepNavy.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                            ? Colors.transparent 
                            : AppColors.deepNavy.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Colored strip on the left edge
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        width: 4,
                        child: Container(color: color),
                      ),
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
    final isDay = hour >= 5 && hour < 18;

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
                      color: Colors.amber.withValues(alpha: 0.12),
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

