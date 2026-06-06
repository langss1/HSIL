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

    return Scaffold(
      backgroundColor: AppColors.bgDarker,
      appBar: AppBar(
        title: const Text('Detail Karyawan'),
        centerTitle: true,
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card (Header)
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Employee Details Info Block
            Text(
              'Informasi Karyawan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDetailSection(isActive),
            const SizedBox(height: 28),

            // Role Management Panel
            Text(
              'Manajemen Akses & Peran',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
            ),
            const SizedBox(height: 12),
            _buildRoleManagementSection(),
            const SizedBox(height: 32),

            // Action Shortcuts
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgCardLight),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.deepNavy],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.bgCardLight,
            backgroundImage: widget.employee.photoUrl != null
                ? NetworkImage(widget.employee.photoUrl!)
                : null,
            child: widget.employee.photoUrl == null
                ? Text(
                    widget.employee.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            widget.employee.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            widget.employee.position,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.safetyOrange,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.employee.department,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(bool isActive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge_outlined, 'NIK / ID', widget.employee.nik),
          const Divider(color: AppColors.bgCardLight, height: 24),
          _buildInfoRow(Icons.email_outlined, 'Email', widget.employee.email),
          const Divider(color: AppColors.bgCardLight, height: 24),
          _buildInfoRow(
            Icons.phone_outlined,
            'No. Telepon',
            widget.employee.phone ?? 'Tidak ada nomor telepon',
          ),
          const Divider(color: AppColors.bgCardLight, height: 24),
          _buildInfoRow(
            Icons.schedule_outlined,
            'Jam Kerja (Shift)',
            '${widget.employee.shiftStart} - ${widget.employee.shiftEnd}',
          ),
          const Divider(color: AppColors.bgCardLight, height: 24),
          _buildInfoRow(
            Icons.toggle_on_outlined,
            'Status Akun',
            isActive ? 'Aktif' : 'Nonaktif',
            valueColor: isActive ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleManagementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Peran Pengguna (User Role)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            dropdownColor: AppColors.bgCard,
            style: const TextStyle(color: AppColors.white, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.bgDarker,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.bgCardLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.safetyOrange),
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : _updateRole,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.safetyOrange,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            RouteConstants.adminAttendanceLog,
            arguments: widget.employee,
          );
        },
        icon: const Icon(Icons.history_outlined, size: 20),
        label: const Text(
          'Lihat Riwayat Kehadiran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.safetyOrange,
          side: const BorderSide(color: AppColors.safetyOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
