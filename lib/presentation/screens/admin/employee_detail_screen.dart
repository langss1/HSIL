import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/themes/color_palette.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/admin_provider.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final AppUser employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late UserRole _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.employee.role;
  }

  Future<void> _updateRole() async {
    if (_selectedRole == widget.employee.role) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peran yang dipilih sama dengan peran saat ini'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final adminProv = context.read<AdminProvider>();
    await adminProv.updateEmployeeRole(widget.employee.userId, _selectedRole);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }

    if (adminProv.errorMessage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengubah peran menjadi ${_selectedRole == UserRole.admin ? "Admin" : "Staff"}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah peran: ${adminProv.errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.employee.isActive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFF8FAFC), // slightly off-white like screenshot
      appBar: AppBar(
        title: Text(
          'Detail Karyawan',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.deepNavy,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card (Header)
            _buildProfileHeader(isDark),
            const SizedBox(height: 24),

            // Employee Details Info Block
            Text(
              'Informasi Karyawan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.deepNavy,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDetailSection(isActive, isDark),
            const SizedBox(height: 28),

            // Role Management Panel
            Text(
              'Manajemen Akses & Peran',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.deepNavy,
                  ),
            ),
            const SizedBox(height: 12),
            _buildRoleManagementSection(isDark),
            const SizedBox(height: 32),

            // Action Shortcuts
            _buildActionButtons(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.safetyOrange.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
        gradient: isDark 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bgCard, AppColors.deepNavy],
              ) 
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAFC), 
                  Color(0xFFFFF0E6), 
                ],
              ),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              image: widget.employee.photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.employee.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.safetyOrange.withValues(alpha: 0.3),
                width: 2.5,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: AppColors.safetyOrange.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: widget.employee.photoUrl == null
                ? Center(
                    child: Text(
                      widget.employee.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.w600,
                        fontSize: 36,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            widget.employee.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.deepNavy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.safetyOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.safetyOrange.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              widget.employee.position.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.employee.department,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColors.deepNavy.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.deepNavy.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.deepNavy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge_outlined, 'NIK / ID', widget.employee.nik, isDark),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.deepNavy.withValues(alpha: 0.05), height: 24),
          _buildInfoRow(Icons.email_outlined, 'Email', widget.employee.email, isDark),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.deepNavy.withValues(alpha: 0.05), height: 24),
          _buildInfoRow(
            Icons.phone_outlined,
            'No. Telepon',
            widget.employee.phone ?? 'Tidak ada nomor telepon',
            isDark,
          ),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.deepNavy.withValues(alpha: 0.05), height: 24),
          _buildInfoRow(
            Icons.schedule_outlined,
            'Jam Kerja (Shift)',
            '${widget.employee.shiftStart} - ${widget.employee.shiftEnd}',
            isDark,
          ),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.deepNavy.withValues(alpha: 0.05), height: 24),
          _buildInfoRow(
            Icons.toggle_on_outlined,
            'Status Akun',
            isActive ? 'Aktif' : 'Nonaktif',
            isDark,
            valueColor: isActive ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8F0FE), // Light blue background
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDark ? AppColors.textSecondary : const Color(0xFF6B8BCC), size: 20), // Light blue icon
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : AppColors.deepNavy.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? (isDark ? AppColors.white : AppColors.deepNavy),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleManagementSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.deepNavy.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.deepNavy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Peran Pengguna (User Role)',
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColors.deepNavy.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            dropdownColor: isDark ? AppColors.bgCard : Colors.white,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.deepNavy, 
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.bgDarker : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.deepNavy.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.safetyOrange, width: 2),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: UserRole.employee,
                child: Text('Staff (Karyawan)'),
              ),
              DropdownMenuItem(
                value: UserRole.admin,
                child: Text('Admin (HRD / Operator)'),
              ),
            ],
            onChanged: (role) {
              if (role != null) {
                setState(() {
                  _selectedRole = role;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _updateRole,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.safetyOrange,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: AppColors.safetyOrange.withOpacity(0.4),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Simpan Perubahan Peran',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            RouteConstants.adminAttendanceLog,
            arguments: widget.employee,
          );
        },
        icon: const Icon(Icons.history_rounded, size: 22),
        label: const Text(
          'Lihat Riwayat Kehadiran',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: AppColors.deepNavy.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
