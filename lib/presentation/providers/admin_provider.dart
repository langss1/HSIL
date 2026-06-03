import 'package:flutter/foundation.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({required this.repository});

  final AdminRepository repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AppUser> _employees = [];
  List<AppUser> get employees => _employees;

  List<AttendanceRecord> _todayAttendance = [];
  List<AttendanceRecord> get todayAttendance => _todayAttendance;

  List<AttendanceRecord> _employeeAttendance = [];
  List<AttendanceRecord> get employeeAttendance => _employeeAttendance;

  int get todayTotalAttendance => _todayAttendance.where((r) => r.status == 'hadir' || r.status == 'telat').length;
  int get todayLates => _todayAttendance.where((r) => r.status == 'telat').length;
  int get todayAbsents => _todayAttendance.where((r) => r.status == 'alpha').length;

  Future<void> fetchDashboardData() async {
    _setLoading(true);
    
    final employeesResult = await repository.getAllEmployees();
    employeesResult.when(
      success: (data) => _employees = data,
      failure: (failure) => _errorMessage = failure.message,
    );

    final attendanceResult = await repository.getTodayAttendance();
    attendanceResult.when(
      success: (data) => _todayAttendance = data,
      failure: (failure) => _errorMessage = failure.message,
    );

    _setLoading(false);
  }

  Future<void> fetchEmployeeAttendance(String employeeId, DateTime startDate, DateTime endDate) async {
    _setLoading(true);
    final result = await repository.getEmployeeAttendance(employeeId, startDate, endDate);
    result.when(
      success: (data) => _employeeAttendance = data,
      failure: (failure) => _errorMessage = failure.message,
    );
    _setLoading(false);
  }

  Future<void> updateEmployeeRole(String employeeId, UserRole newRole) async {
    _setLoading(true);
    final result = await repository.updateEmployeeRole(employeeId, newRole);
    result.when(
      success: (_) {
        final index = _employees.indexWhere((e) => e.userId == employeeId);
        if (index != -1) {
          _employees[index] = AppUser(
            userId: _employees[index].userId,
            nik: _employees[index].nik,
            name: _employees[index].name,
            email: _employees[index].email,
            role: newRole,
            department: _employees[index].department,
            position: _employees[index].position,
            shiftStart: _employees[index].shiftStart,
            shiftEnd: _employees[index].shiftEnd,
            isActive: _employees[index].isActive,
            phone: _employees[index].phone,
            photoUrl: _employees[index].photoUrl,
            createdAt: _employees[index].createdAt,
            updatedAt: _employees[index].updatedAt,
          );
        }
      },
      failure: (failure) => _errorMessage = failure.message,
    );
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
