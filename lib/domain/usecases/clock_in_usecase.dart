import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../entities/attendance_record.dart';
import '../entities/gps_validation_result.dart';
import '../repositories/attendance_repository.dart';

/// Handles the clock-in business logic with GPS validation.
class ClockInUseCase {
  const ClockInUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<AppResult<AttendanceRecord>> call({
    required String employeeId,
    required String employeeName,
    required GPSValidationResult gpsResult,
    required String imageUrl,
  }) async {
    // 1. Validasi hari libur (Sabtu & Minggu)
    final todayWeekday = DateTime.now().weekday;
    if (todayWeekday == DateTime.saturday || todayWeekday == DateTime.sunday) {
      return const AppFailure(
        AttendanceFailure(
          'Tidak dapat melakukan clock-in pada hari libur (Sabtu & Minggu).',
          code: 'WEEKEND_NOT_ALLOWED',
        ),
      );
    }

    // 2. Validate GPS — must be in area
    if (!gpsResult.isInArea) {
      return AppFailure(
        GPSFailure(
          'Anda berada di luar radius kantor '
          '(${gpsResult.distanceMeters.toStringAsFixed(0)}m). '
          'Jarak maksimal ${AppConstants.officeRadiusMeters.toStringAsFixed(0)}m.',
          code: 'OUTSIDE_AREA',
        ),
      );
    }

    // 3. Check if already clocked in today
    final todayResult = await _repository.getTodayAttendance(employeeId);
    final today = todayResult.when(
      success: (record) => record,
      failure: (_) => null,
    );

    if (today != null && today.hasClockedIn) {
      return const AppFailure(
        AttendanceFailure(
          'Anda sudah melakukan clock-in hari ini.',
          code: 'ALREADY_CLOCKED_IN',
        ),
      );
    }

    // 4. Perform clock-in
    return _repository.clockIn(
      employeeId: employeeId,
      employeeName: employeeName,
      gpsResult: gpsResult,
      imageUrl: imageUrl,
    );
  }
}
