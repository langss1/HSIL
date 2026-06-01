import 'package:flutter_test/flutter_test.dart';
import 'package:hsil_attendance/core/errors/failures.dart';
import 'package:hsil_attendance/core/utils/app_result.dart';
import 'package:hsil_attendance/domain/entities/gps_validation_result.dart';
import 'package:hsil_attendance/domain/repositories/location_repository.dart';
import 'package:hsil_attendance/domain/usecases/validate_gps_usecase.dart';

// Manual Mock implementation of LocationRepository
class MockLocationRepository implements LocationRepository {
  bool serviceEnabled = true;
  bool hasPermissionGranted = true;
  bool requestPermissionResult = true;
  GPSValidationResult validationResult = GPSValidationResult(
    isInArea: true,
    distanceMeters: 50,
    latitude: -6.200000,
    longitude: 106.816666,
    status: 'IN_AREA',
    timestamp: DateTime.now(),
  );
  bool shouldThrowError = false;

  @override
  Future<bool> hasLocationPermission() async => hasPermissionGranted;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<bool> requestLocationPermission() async => requestPermissionResult;

  @override
  Future<GPSValidationResult> validateCurrentLocation() async {
    if (shouldThrowError) throw Exception('Mock exception');
    return validationResult;
  }

  @override
  Stream<GPSValidationResult> watchLocationStream() {
    return Stream.value(validationResult);
  }
}

void main() {
  late MockLocationRepository mockRepository;
  late ValidateGPSUseCase usecase;

  setUp(() {
    mockRepository = MockLocationRepository();
    usecase = ValidateGPSUseCase(mockRepository);
  });

  group('ValidateGPSUseCase Business Logic', () {
    test('Returns AppFailure if location service is disabled', () async {
      mockRepository.serviceEnabled = false;

      final result = await usecase();

      expect(result, isA<AppFailure<GPSValidationResult>>());
      final failure = (result as AppFailure).error as GPSFailure;
      expect(failure.code, 'LOCATION_SERVICE_DISABLED');
    });

    test('Returns AppFailure if location permission is denied', () async {
      mockRepository.hasPermissionGranted = false;
      mockRepository.requestPermissionResult = false; // Denied after requesting

      final result = await usecase();

      expect(result, isA<AppFailure<GPSValidationResult>>());
      final failure = (result as AppFailure).error as GPSFailure;
      expect(failure.code, 'PERMISSION_DENIED');
    });

    test('Returns AppSuccess with valid result if all checks pass', () async {
      final result = await usecase();

      expect(result, isA<AppSuccess<GPSValidationResult>>());
      final data = (result as AppSuccess<GPSValidationResult>).value;
      expect(data.isInArea, isTrue);
      expect(data.distanceMeters, 50);
    });

    test('Returns AppFailure if repository throws an exception', () async {
      mockRepository.shouldThrowError = true;

      final result = await usecase();

      expect(result, isA<AppFailure<GPSValidationResult>>());
      final failure = (result as AppFailure).error as GPSFailure;
      expect(failure.message, contains('Gagal memvalidasi lokasi'));
    });
  });
}
