import '../../core/utils/app_result.dart';
import '../entities/app_user.dart';
import '../entities/attendance_record.dart';

abstract class AdminRepository {
  Future<AppResult<List<AppUser>>> getAllEmployees();
  
  Future<AppResult<List<AttendanceRecord>>> getTodayAttendance();
  
  Future<AppResult<List<AttendanceRecord>>> getEmployeeAttendance(String employeeId, DateTime startDate, DateTime endDate);

  Future<AppResult<void>> updateEmployeeRole(String employeeId, UserRole newRole);
}
