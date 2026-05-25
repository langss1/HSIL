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
                    FadeSlide(child: _Header(userName: user?.name ?? 'HSIL')),
                    const SizedBox(height: Spacing.lg),
                    FadeSlide(
                      delay: const Duration(milliseconds: 80),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'Memuat profil...',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.headlineMedium,
                                      ),
                                      const SizedBox(height: Spacing.xs),
                                      Text(
                                        user == null
                                            ? 'Role akan muncul setelah profil Firestore terbaca.'
                                            : '${user.department} | ${user.position}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                StatusPill(
                                  label:
                                      user?.role.value.toUpperCase() ?? 'SYNC',
                                  icon:
                                      user?.isAdmin == true
                                          ? Icons.admin_panel_settings_rounded
                                          : Icons.engineering_rounded,
                                  color:
                                      user?.isAdmin == true
                                          ? AppColors.safetyOrange
                                          : AppColors.info,
                                ),
                              ],
                            ),
                            const SizedBox(height: Spacing.lg),
                            const _TodayActionCard(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    const FadeSlide(
                      delay: Duration(milliseconds: 160),
                      child: _StatsGrid(),
                    ),
                    const SizedBox(height: Spacing.lg),
                    FadeSlide(
                      delay: const Duration(milliseconds: 240),
                      child:
                          user?.isAdmin == true
                              ? const _AdminSkeleton()
                              : const _EmployeeSkeleton(),
                    ),
                    const SizedBox(height: Spacing.lg),
                    AppButton(
                      label: 'Logout',
                      icon: Icons.logout_rounded,
                      isOutlined: true,
                      onPressed: () => context.read<AuthController>().signOut(),
                    ),
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

class _Header extends StatelessWidget {
  const _Header({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat bekerja,',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(userName, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        const StatusPill(
          label: AppConstants.officeName,
          icon: Icons.factory_rounded,
          color: AppColors.safetyOrange,
        ),
      ],
    );
  }
}

class _TodayActionCard extends StatelessWidget {
  const _TodayActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.safetyOrange, Color(0xFFFF8E63)],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fingerprint_rounded,
            color: AppColors.white,
            size: 42,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clock-in flow siap disambungkan',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Tahap berikutnya: GPS radius + face capture.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: .82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Hadir', '0', AppColors.success, Icons.check_circle_rounded),
      ('Telat', '0', AppColors.warning, Icons.schedule_rounded),
      ('Izin', '0', AppColors.info, Icons.event_available_rounded),
      ('Alpha', '0', AppColors.error, Icons.cancel_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 720 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: Spacing.md,
            crossAxisSpacing: Spacing.md,
            childAspectRatio: columns == 4 ? 1.45 : 1.2,
          ),
          itemBuilder: (context, index) {
            final (label, value, color, icon) = cards[index];
            return GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color),
                  const Spacer(),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EmployeeSkeleton extends StatelessWidget {
  const _EmployeeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(
            label: 'Employee dashboard skeleton',
            icon: Icons.person_rounded,
            color: AppColors.info,
          ),
          SizedBox(height: Spacing.md),
          SkeletonLoader(height: 18, width: 220),
          SizedBox(height: Spacing.sm),
          SkeletonLoader(height: 84),
        ],
      ),
    );
  }
}

class _AdminSkeleton extends StatelessWidget {
  const _AdminSkeleton();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(
            label: 'Admin monitoring skeleton',
            icon: Icons.monitor_heart_rounded,
            color: AppColors.safetyOrange,
          ),
          SizedBox(height: Spacing.md),
          SkeletonLoader(height: 18, width: 260),
          SizedBox(height: Spacing.sm),
          SkeletonLoader(height: 120),
        ],
      ),
    );
  }
}
