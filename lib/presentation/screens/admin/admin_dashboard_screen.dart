import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/themes/color_palette.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_controller.dart';

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

  Widget _buildAppBar(BuildContext context, String adminName) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HRD Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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
              onPressed: () {
                context.read<AuthController>().signOut();
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              tooltip: 'Logout',
            ),
          ],
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
              child: _StatCard(
                title: 'Hadir',
                value: adminProv.todayTotalAttendance.toString(),
                color: AppColors.statusHadir,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Terlambat',
                value: adminProv.todayLates.toString(),
                color: AppColors.statusTelat,
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Alpha',
                value: adminProv.todayAbsents.toString(),
                color: AppColors.statusAlpha,
                icon: Icons.cancel_outlined,
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
        childAspectRatio: 1.1,
        children: [
          _MenuCard(
            title: 'Karyawan',
            subtitle: 'Data & Role',
            icon: Icons.people_outline,
            color: AppColors.info,
            onTap: () => Navigator.pushNamed(context, RouteConstants.employeeList),
          ),
          _MenuCard(
            title: 'Peta Kehadiran',
            subtitle: 'Live Tracking',
            icon: Icons.map_outlined,
            color: AppColors.safetyOrange,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Peta (Hari 11) belum diimplementasi'))),
          ),
          _MenuCard(
            title: 'Grafik KPI',
            subtitle: 'Analisis Performa',
            icon: Icons.bar_chart_outlined,
            color: AppColors.success,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Grafik KPI (Hari 11) belum diimplementasi'))),
          ),
          _MenuCard(
            title: 'Log Kehadiran',
            subtitle: 'Export CSV',
            icon: Icons.history_outlined,
            color: Colors.purpleAccent,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Log Kehadiran (Hari 12) belum diimplementasi'))),
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
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.bgCardLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
