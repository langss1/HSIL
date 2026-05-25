import 'package:flutter_test/flutter_test.dart';
import 'package:hsil_attendance/core/constants/app_constants.dart';
import 'package:hsil_attendance/core/utils/haversine_util.dart';
import 'package:hsil_attendance/data/datasources/firebase_auth_data_source.dart';
import 'package:hsil_attendance/data/models/user_model.dart';
import 'package:hsil_attendance/domain/entities/app_user.dart';

void main() {
  test('NIK login email uses internal factory domain', () {
    expect(
      FirebaseAuthDataSource.nikToEmail('0123456789'),
      '0123456789@${AppConstants.nikEmailDomain}',
    );
  });

  test('UserModel follows Firestore role contract', () {
    final user = UserModel.fromJson({
      'userId': 'uid-1',
      'nik': '0123456789',
      'name': 'Admin HSIL',
      'email': '0123456789@factory.internal',
      'role': 'admin',
      'department': 'HRD',
      'position': 'Supervisor',
      'shiftStart': '08:00',
      'shiftEnd': '17:00',
      'isActive': true,
    });

    expect(user.role, UserRole.admin);
    expect(user.isAdmin, isTrue);
    expect(user.toJson()['nik'], '0123456789');
  });

  test('Haversine returns zero distance for identical coordinates', () {
    final distance = HaversineUtil.distanceInMeters(
      fromLatitude: -6.2088,
      fromLongitude: 106.8456,
      toLatitude: -6.2088,
      toLongitude: 106.8456,
    );

    expect(distance, closeTo(0, .001));
  });
}
