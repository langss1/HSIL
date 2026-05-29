import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../entities/gps_validation_result.dart';
import '../repositories/location_repository.dart';

/// Validates the current device GPS location against the office geofence.
///
/// Checks permissions, location service status, and computes distance.
class ValidateGPSUseCase {
  const ValidateGPSUseCase(this._repository);

  final LocationRepository _repository;

  Future<AppResult<GPSValidationResult>> call() async {
    try {
      // 1. Check if location service is enabled
      final serviceEnabled = await _repository.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const AppFailure(
          GPSFailure(
            'Layanan lokasi tidak aktif. Nyalakan GPS di pengaturan perangkat.',
            code: 'LOCATION_SERVICE_DISABLED',
          ),
        );
      }

      // 2. Check / request permission
      final hasPermission = await _repository.hasLocationPermission();
      if (!hasPermission) {
        final granted = await _repository.requestLocationPermission();
        if (!granted) {
          return const AppFailure(
            GPSFailure(
              'Izin lokasi ditolak. Aplikasi membutuhkan akses GPS.',
              code: 'PERMISSION_DENIED',
            ),
          );
        }
      }

      // 3. Validate current location
      final result = await _repository.validateCurrentLocation();
      return AppSuccess(result);
    } catch (e) {
      return AppFailure(
        GPSFailure('Gagal memvalidasi lokasi: $e'),
      );
    }
  }
}
