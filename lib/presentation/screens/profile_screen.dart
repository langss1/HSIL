import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(color: isDark ? Colors.white : AppColors.deepNavy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              children: [
                const SizedBox(height: Spacing.xl),
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.safetyOrange, Color(0xFFE85A23)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'K',
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Text(
                  user?.name ?? 'Nama Karyawan',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.position ?? 'Posisi',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: Spacing.xxl),
                AppButton(
                  label: 'Keluar',
                  icon: Icons.logout_rounded,
                  isOutlined: true,
                  onPressed: () => context.read<AuthController>().signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
