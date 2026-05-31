import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/route_constants.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: Text('Profil Karyawan', style: TextStyle(color: isDark ? Colors.white : AppColors.deepNavy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Column(
          children: [
            _buildHeader(context, user.name, user.position, user.department),
            const SizedBox(height: Spacing.lg),
            _buildInfoCard(context, user),
            const SizedBox(height: Spacing.lg),
            _buildActionsCard(context),
            const SizedBox(height: Spacing.xl),
            const Text('v1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String position, String department) {
    final initials = name.isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : '?';

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.safetyOrange, Color(0xFFFF9E45)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: Spacing.md),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: Spacing.xs),
        Text('$position • $department', style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Personal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: Spacing.md),
          _buildInfoRow('NIK', user.nik, Icons.badge_rounded),
          const Divider(height: 24),
          _buildInfoRow('Email', user.email, Icons.email_rounded),
          const Divider(height: 24),
          _buildInfoRow('No. HP', (user.phone?.isNotEmpty == true) ? user.phone! : 'Belum diisi', Icons.phone_rounded),
          const Divider(height: 24),
          _buildInfoRow('Shift', '${user.shiftStart} - ${user.shiftEnd}', Icons.schedule_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Column(
      children: [
        _buildActionItem(context, 'Edit Profil', Icons.edit_rounded, RouteConstants.editProfile),
        const SizedBox(height: Spacing.sm),
        _buildActionItem(context, 'Ubah Password', Icons.lock_rounded, RouteConstants.changePassword),
        const SizedBox(height: Spacing.sm),
        _buildActionItem(context, 'Notifikasi', Icons.notifications_rounded, RouteConstants.notifications),
        const SizedBox(height: Spacing.sm),
        _buildActionItem(
          context, 
          'Tentang Aplikasi', 
          Icons.info_rounded, 
          null,
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Tentang Aplikasi'),
                content: const Text('Aplikasi Presensi Karyawan v1.0.0\nDikembangkan untuk tugas akhir.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))
                ],
              ),
            );
          }
        ),
        const SizedBox(height: Spacing.sm),
        GlassCard(
          onTap: () => context.read<AuthController>().signOut(),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: Spacing.md),
              const Expanded(child: Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, String? route, {VoidCallback? onTap}) {
    return GlassCard(
      onTap: onTap ?? () {
        if (route != null) {
          Navigator.of(context).pushNamed(route);
        }
      },
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.safetyOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.safetyOrange, size: 20),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
