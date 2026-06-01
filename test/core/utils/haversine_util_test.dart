import 'package:flutter_test/flutter_test.dart';
import 'package:hsil_attendance/core/utils/haversine_util.dart';

void main() {
  group('HaversineUtil Business Logic', () {
    test('distanceInMeters returns 0 for identical coordinates', () {
      final distance = HaversineUtil.distanceInMeters(
        fromLatitude: -6.2088,
        fromLongitude: 106.8456,
        toLatitude: -6.2088,
        toLongitude: 106.8456,
      );

      expect(distance, closeTo(0, 0.001));
    });

    test('distanceInMeters calculates roughly correct distance between two points (Monas to Bundaran HI)', () {
      // Monas
      const lat1 = -6.175392;
      const lon1 = 106.827153;
      // Bundaran HI
      const lat2 = -6.195000;
      const lon2 = 106.823000;

      final distance = HaversineUtil.distanceInMeters(
        fromLatitude: lat1,
        fromLongitude: lon1,
        toLatitude: lat2,
        toLongitude: lon2,
      );

      // Distance should be around 2.22 kilometers (2220 meters)
      expect(distance, greaterThan(2100));
      expect(distance, lessThan(2300));
    });

    test('distanceInMeters calculates same distance regardless of direction', () {
      const lat1 = -6.175392;
      const lon1 = 106.827153;
      const lat2 = -6.195000;
      const lon2 = 106.823000;

      final distanceForward = HaversineUtil.distanceInMeters(
        fromLatitude: lat1,
        fromLongitude: lon1,
        toLatitude: lat2,
        toLongitude: lon2,
      );

      final distanceBackward = HaversineUtil.distanceInMeters(
        fromLatitude: lat2,
        fromLongitude: lon2,
        toLatitude: lat1,
        toLongitude: lon1,
      );

      expect(distanceForward, equals(distanceBackward));
    });
  });
}
