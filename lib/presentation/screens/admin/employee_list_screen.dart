import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/themes/color_palette.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/entities/app_user.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Daftar Karyawan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: adminProv.isLoading && adminProv.employees.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
          : RefreshIndicator(
              onRefresh: () => adminProv.fetchDashboardData(),
              color: AppColors.safetyOrange,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: adminProv.employees.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final employee = adminProv.employees[index];
                  return _EmployeeTile(employee: employee, isDark: isDark);
                },
              ),
            ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final AppUser employee;
  final bool isDark;

  const _EmployeeTile({required this.employee, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = employee.role == UserRole.admin;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.deepNavy.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.deepNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, RouteConstants.employeeDetail, arguments: employee);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgCardLight : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    image: employee.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(employee.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.deepNavy.withValues(alpha: 0.1),
                    ),
                  ),
                  child: employee.photoUrl == null
                      ? Center(
                          child: Text(
                            employee.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.deepNavy,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.deepNavy,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${employee.department} • ${employee.position}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAdmin 
                        ? AppColors.safetyOrange.withValues(alpha: 0.15) 
                        : AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAdmin 
                          ? AppColors.safetyOrange.withValues(alpha: 0.5) 
                          : AppColors.info.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isAdmin ? 'Admin' : 'Staff',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? AppColors.safetyOrange : AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
