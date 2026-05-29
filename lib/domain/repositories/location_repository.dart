import '../entities/gps_validation_result.dart';

/// Contract for GPS location operations.
abstract interface class LocationRepository {
  /// Validates the current device location against the office geofence.
  Future<GPSValidationResult> validateCurrentLocation();

  /// Streams real-time GPS validation results.
  Stream<GPSValidationResult> watchLocationStream();

  /// Checks whether the device location service is enabled.
  Future<bool> isLocationServiceEnabled();

  /// Requests location permission from the user.
  ///
  /// Returns `true` if permission was granted.
  Future<bool> requestLocationPermission();

  /// Checks if location permission is already granted.
  Future<bool> hasLocationPermission();
}
