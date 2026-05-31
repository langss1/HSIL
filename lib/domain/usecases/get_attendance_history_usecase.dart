import '../../core/utils/app_result.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

/// Retrieves attendance history for a specific month.
class GetAttendanceHistoryUseCase {
  const GetAttendanceHistoryUseCase(this._repository);

  final AttendanceRepository _repository;

  /// Returns all attendance records for the given [year] and [month].
  Future<AppResult<List<AttendanceRecord>>> call({
    required String employeeId,
    required int year,
    required int month,
  }) {
    // Calculate start and end dates for the month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Last day of month

    return _repository.getAttendanceByDateRange(
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
