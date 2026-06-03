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

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('Daftar Karyawan'),
        centerTitle: true,
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
      ),
      body: adminProv.isLoading && adminProv.employees.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
          : RefreshIndicator(
              onRefresh: () => adminProv.fetchDashboardData(),
              color: AppColors.safetyOrange,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: adminProv.employees.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final employee = adminProv.employees[index];
                  return _EmployeeTile(employee: employee);
                },
              ),
            ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final AppUser employee;

  const _EmployeeTile({required this.employee});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = employee.role == UserRole.admin;
    
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // Navigate to employee details when implemented
          // Navigator.pushNamed(context, RouteConstants.employeeDetail, arguments: employee);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee detail view not yet implemented')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.bgCardLight,
                backgroundImage: employee.photoUrl != null
                    ? NetworkImage(employee.photoUrl!)
                    : null,
                child: employee.photoUrl == null
                    ? Text(
                        employee.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.department} • ${employee.position}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin 
                      ? AppColors.safetyOrange.withOpacity(0.15) 
                      : AppColors.info.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAdmin ? AppColors.safetyOrange : AppColors.info,
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
    );
  }
}
