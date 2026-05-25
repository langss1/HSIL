import 'dart:math' as math;

/// Calculates geodesic distance using the Haversine formula.
class HaversineUtil {
  const HaversineUtil._();

  static const double _earthRadiusMeters = 6371000;

  static double distanceInMeters({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    final dLat = _toRadians(toLatitude - fromLatitude);
    final dLon = _toRadians(toLongitude - fromLongitude);
    final lat1 = _toRadians(fromLatitude);
    final lat2 = _toRadians(toLatitude);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  static double _toRadians(double degree) => degree * math.pi / 180;
}
