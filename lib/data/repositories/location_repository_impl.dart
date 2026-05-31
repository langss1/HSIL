import '../../core/constants/app_constants.dart';
import '../../core/utils/haversine_util.dart';
import '../../domain/entities/gps_validation_result.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/geolocator_data_source.dart';

/// Concrete [LocationRepository] that validates device position against
/// the office geofence using Haversine distance calculation.
class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({required GeolocatorDataSource geolocatorDataSource})
    : _geolocator = geolocatorDataSource;

  final GeolocatorDataSource _geolocator;

  @override
  Future<GPSValidationResult> validateCurrentLocation() async {
    final position = await _geolocator.getCurrentPosition();
    return _buildResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }

  @override
  Stream<GPSValidationResult> watchLocationStream() {
    return _geolocator.getPositionStream().map(
      (position) => _buildResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      ),
    );
  }

  @override
  Future<bool> isLocationServiceEnabled() => _geolocator.isServiceEnabled();

  @override
  Future<bool> requestLocationPermission() => _geolocator.requestPermission();

  @override
  Future<bool> hasLocationPermission() => _geolocator.checkPermission();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Builds a [GPSValidationResult] from raw coordinates by calculating
  /// the Haversine distance to the office and comparing it with the
  /// configured geofence radius.
  GPSValidationResult _buildResult({
    required double latitude,
    required double longitude,
    required double accuracy,
  }) {
    final distance = HaversineUtil.distanceInMeters(
      fromLatitude: latitude,
      fromLongitude: longitude,
      toLatitude: AppConstants.officeLatitude,
      toLongitude: AppConstants.officeLongitude,
    );

    print("USER_LOCATION_DEBUG: $latitude, $longitude");

    final isInArea = distance <= AppConstants.officeRadiusMeters;

    return GPSValidationResult(
      isInArea: isInArea,
      distanceMeters: distance,
      latitude: latitude,
      longitude: longitude,
      status: isInArea ? 'IN_AREA' : 'OUTSIDE_AREA',
      timestamp: DateTime.now(),
      accuracy: accuracy,
    );
  }
}
