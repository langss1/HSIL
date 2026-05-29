import '../../core/utils/app_result.dart';
import '../entities/attendance_record.dart';
import '../entities/gps_validation_result.dart';

/// Contract for attendance record operations.
abstract interface class AttendanceRepository {
  /// Records a clock-in event for the given employee.
  Future<AppResult<AttendanceRecord>> clockIn({
    required String employeeId,
    required String employeeName,
    required GPSValidationResult gpsResult,
  });

  /// Records a clock-out event for an existing attendance record.
  Future<AppResult<AttendanceRecord>> clockOut({
    required String attendanceId,
    required GPSValidationResult gpsResult,
  });

  /// Retrieves today's attendance record for the given employee.
  Future<AppResult<AttendanceRecord?>> getTodayAttendance(String employeeId);

  /// Streams real-time updates for today's attendance record.
  Stream<AttendanceRecord?> watchTodayAttendance(String employeeId);

  /// Retrieves attendance records within a date range.
  Future<AppResult<List<AttendanceRecord>>> getAttendanceByDateRange({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Calculates weekly attendance statistics.
  Future<AppResult<Map<String, int>>> getWeeklyStats(String employeeId);
}
