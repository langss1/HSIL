import 'package:flutter/foundation.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/registration_request.dart';
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

  List<AttendanceRecord> _weeklyAttendance = [];
  List<AttendanceRecord> get weeklyAttendance => _weeklyAttendance;

  int get todayTotalAttendance => _todayAttendance.where((r) => r.status == 'hadir' || r.status == 'telat').length;
  int get todayLates => _todayAttendance.where((r) => r.status == 'telat').length;
  int get todayAbsents {
    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    
    if (isWeekend) {
      // Pada hari Sabtu/Minggu, jangan anggap karyawan yang belum absen sebagai Alpha
      return _todayAttendance.where((r) => r.status == 'alpha').length;
    }

    int total = _employees.length;
    if (total == 0) return _todayAttendance.where((r) => r.status == 'alpha').length;
    int remaining = total - todayTotalAttendance - todayLeaves;
    return remaining > 0 ? remaining : 0;
  }
  int get todayLeaves => _todayAttendance.where((r) => r.status == 'izin' || r.status == 'sakit').length;

  Future<void> fetchDashboardData() async {
    _setLoading(true);
    
    final employeesResult = await repository.getAllEmployees();
    employeesResult.when(
      success: (data) => _employees = List<AppUser>.from(data),
      failure: (failure) => _errorMessage = failure.message,
    );

    final attendanceResult = await repository.getTodayAttendance();
    attendanceResult.when(
      success: (data) => _todayAttendance = data,
      failure: (failure) => _errorMessage = failure.message,
    );

    // Fetch weekly attendance (last 7 days including today)
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 6));
    final weeklyResult = await repository.getAttendanceRange(startDate, now);
    weeklyResult.when(
      success: (data) => _weeklyAttendance = data,
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
    _errorMessage = null;
    _setLoading(true);
    final result = await repository.updateEmployeeRole(employeeId, newRole);
    result.when(
      success: (_) {
        _errorMessage = null;
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

  Future<bool> deleteEmployee(String employeeId) async {
    _errorMessage = null;
    _setLoading(true);
    final result = await repository.deleteEmployee(employeeId);
    bool success = false;
    result.when(
      success: (_) {
        _errorMessage = null;
        _employees.removeWhere((e) => e.userId == employeeId);
        success = true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        success = false;
      },
    );
    _setLoading(false);
    return success;
  }

  Future<bool> addEmployee(RegistrationRequest request) async {
    _errorMessage = null;
    _setLoading(true);
    
    final result = await repository.addEmployee(request);
    bool success = false;
    
    result.when(
      success: (_) async {
        _errorMessage = null;
        success = true;
        // Refresh employee list after successful addition
        await fetchDashboardData();
      },
      failure: (failure) {
        _errorMessage = failure.message;
        success = false;
      },
    );
    
    if (success) {
      // _setLoading(false) is called inside fetchDashboardData, 
      // but we ensure it's called just in case
      _setLoading(false);
    } else {
      _setLoading(false);
    }
    
    return success;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
