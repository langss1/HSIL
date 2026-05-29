import 'package:geolocator/geolocator.dart';

/// Thin wrapper around the `geolocator` package for GPS operations.
///
/// Keeps third-party API details out of the repository layer and makes
/// GPS behaviour easier to mock in tests.
class GeolocatorDataSource {
  const GeolocatorDataSource();

  /// Whether the device's location service (GPS / network) is turned on.
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  /// Checks if location permission is currently granted or limited.
  ///
  /// Returns `true` when the permission is [LocationPermission.whileInUse]
  /// or [LocationPermission.always].
  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Requests location permission from the user.
  ///
  /// Returns `true` if the user granted [LocationPermission.whileInUse]
  /// or [LocationPermission.always].
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Returns the device's current position using high accuracy.
  Future<Position> getCurrentPosition() => Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );

  /// Streams real-time position updates.
  ///
  /// [distanceFilter] specifies the minimum displacement in meters before
  /// a new position update is emitted. Defaults to 10 meters.
  Stream<Position> getPositionStream({int distanceFilter = 10}) =>
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter,
        ),
      );
}
