import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/themes/color_palette.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/fade_slide.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
    final authProv = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bgDarker,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => adminProv.fetchDashboardData(),
          color: AppColors.safetyOrange,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context, authProv.user?.name ?? 'Admin'),
              if (adminProv.isLoading && adminProv.todayAttendance.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.safetyOrange),
                  ),
                )
              else ...[
                _buildStatsCards(context, adminProv),
                _buildMenuGrid(context),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.bgCardLight),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
              SizedBox(width: 12),
              Text(
                'Konfirmasi Keluar',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari Admin Dashboard?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthController>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, String adminName) {
    return SliverToBoxAdapter(
      child: FadeSlide(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, $adminName',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: AppColors.error),
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, AdminProvider adminProv) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: FadeSlide(
                delay: Duration.zero,
                child: _StatCard(
                  title: 'Hadir',
                  value: adminProv.todayTotalAttendance.toString(),
                  color: AppColors.statusHadir,
                  icon: Icons.check_circle_outline,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FadeSlide(
                delay: const Duration(milliseconds: 100),
                child: _StatCard(
                  title: 'Terlambat',
                  value: adminProv.todayLates.toString(),
                  color: AppColors.statusTelat,
                  icon: Icons.timer_outlined,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FadeSlide(
                delay: const Duration(milliseconds: 200),
                child: _StatCard(
                  title: 'Alpha',
                  value: adminProv.todayAbsents.toString(),
                  color: AppColors.statusAlpha,
                  icon: Icons.cancel_outlined,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.92,
        children: [
          FadeSlide(
            delay: const Duration(milliseconds: 300),
            child: _MenuCard(
              title: 'Karyawan',
              subtitle: 'Data & Role',
              icon: Icons.people_outline,
              color: AppColors.info,
              onTap: () => Navigator.pushNamed(context, RouteConstants.employeeList),
            ),
          ),
          FadeSlide(
            delay: const Duration(milliseconds: 400),
            child: _MenuCard(
              title: 'Peta Kehadiran',
              subtitle: 'Live Tracking',
              icon: Icons.map_outlined,
              color: AppColors.safetyOrange,
              onTap: () => Navigator.pushNamed(context, RouteConstants.adminMap),
            ),
          ),
          FadeSlide(
            delay: const Duration(milliseconds: 500),
            child: _MenuCard(
              title: 'Grafik KPI',
              subtitle: 'Analisis Performa',
              icon: Icons.bar_chart_outlined,
              color: AppColors.success,
              onTap: () => Navigator.pushNamed(context, RouteConstants.kpiDashboard),
            ),
          ),
          FadeSlide(
            delay: const Duration(milliseconds: 600),
            child: _MenuCard(
              title: 'Log Kehadiran',
              subtitle: 'Export CSV',
              icon: Icons.history_outlined,
              color: const Color(0xFFA78BFA),
              onTap: () => Navigator.pushNamed(context, RouteConstants.adminAttendanceLog),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              color: AppColors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.bgCardLight.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
