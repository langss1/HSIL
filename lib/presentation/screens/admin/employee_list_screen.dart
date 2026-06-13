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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredEmployees = adminProv.employees.where((e) {
      final query = _searchQuery.toLowerCase();
      return e.name.toLowerCase().contains(query) ||
             e.department.toLowerCase().contains(query) ||
             e.position.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Daftar Karyawan',
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
      body: adminProv.isLoading && adminProv.employees.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: TextStyle(color: isDark ? Colors.white : AppColors.deepNavy),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, departemen, atau posisi...',
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white54 : AppColors.textSecondary),
                      filled: true,
                      fillColor: isDark ? AppColors.bgCard : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? Colors.transparent : AppColors.deepNavy.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white30 : AppColors.deepNavy.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => adminProv.fetchDashboardData(),
                    color: AppColors.safetyOrange,
                    child: filteredEmployees.isEmpty
                        ? ListView( // empty state needs listview for refresh indicator
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                              Center(
                                child: Text(
                                  'Pencarian tidak ditemukan',
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            itemCount: filteredEmployees.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final employee = filteredEmployees[index];
                              return _EmployeeTile(employee: employee, isDark: isDark);
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteConstants.adminAddEmployee);
        },
        backgroundColor: AppColors.safetyOrange,
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
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
