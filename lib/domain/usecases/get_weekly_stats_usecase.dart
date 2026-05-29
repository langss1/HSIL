import '../../core/utils/app_result.dart';
import '../repositories/attendance_repository.dart';

/// Retrieves weekly attendance statistics for an employee.
class GetWeeklyStatsUseCase {
  const GetWeeklyStatsUseCase(this._repository);

  final AttendanceRepository _repository;

  /// Returns a map with keys: 'hadir', 'telat', 'izin', 'alpha'.
  Future<AppResult<Map<String, int>>> call(String employeeId) {
    return _repository.getWeeklyStats(employeeId);
  }
}
