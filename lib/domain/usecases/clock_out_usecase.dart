import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../entities/attendance_record.dart';
import '../entities/gps_validation_result.dart';
import '../repositories/attendance_repository.dart';

/// Handles the clock-out business logic with GPS validation.
class ClockOutUseCase {
  const ClockOutUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<AppResult<AttendanceRecord>> call({
    required String attendanceId,
    required GPSValidationResult gpsResult,
  }) async {
    // 1. Validate GPS — must be in area
    if (!gpsResult.isInArea) {
      return AppFailure(
        GPSFailure(
          'Anda berada di luar radius kantor '
          '(${gpsResult.distanceMeters.toStringAsFixed(0)}m). '
          'Clock-out harus dilakukan di area kantor.',
          code: 'OUTSIDE_AREA',
        ),
      );
    }

    // 2. Perform clock-out
    return _repository.clockOut(
      attendanceId: attendanceId,
      gpsResult: gpsResult,
    );
  }
}
