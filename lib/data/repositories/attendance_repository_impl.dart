import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../../core/utils/date_util.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/gps_validation_result.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/firestore_attendance_data_source.dart';
import '../models/attendance_model.dart';

/// Concrete [AttendanceRepository] backed by Firestore.
///
/// Every public method returns an [AppResult] so the presentation layer
/// never has to deal with raw exceptions.
class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({
    required FirestoreAttendanceDataSource attendanceDataSource,
    String shiftStart = '08:00',
  }) : _dataSource = attendanceDataSource,
       _shiftStart = shiftStart;

  final FirestoreAttendanceDataSource _dataSource;

  /// Default shift start time used to determine `hadir` vs `telat`.
  final String _shiftStart;

  // ---------------------------------------------------------------------------
  // Clock-in
  // ---------------------------------------------------------------------------

  @override
  Future<AppResult<AttendanceRecord>> clockIn({
    required String employeeId,
    required String employeeName,
    required GPSValidationResult gpsResult,
    required String imageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final dateKey = DateUtil.toDateKey(now);

      final model = AttendanceModel.forClockIn(
        employeeId: employeeId,
        employeeName: employeeName,
        date: dateKey,
        clockIn: now,
        latitude: gpsResult.latitude,
        longitude: gpsResult.longitude,
        distanceMeters: gpsResult.distanceMeters,
        isInArea: gpsResult.isInArea,
        imageUrl: imageUrl,
        shiftStart: _shiftStart,
      );

      await _dataSource.saveClockIn(model);
      return AppSuccess(model);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  // ---------------------------------------------------------------------------
  // Clock-out
  // ---------------------------------------------------------------------------

  @override
  Future<AppResult<AttendanceRecord>> clockOut({
    required String attendanceId,
    required GPSValidationResult gpsResult,
    required String imageUrl,
  }) async {
    try {
      final now = DateTime.now();

      final fields = <String, dynamic>{
        'clockOut': now,
        'clockOutLat': gpsResult.latitude,
        'clockOutLng': gpsResult.longitude,
        'clockOutDistance': gpsResult.distanceMeters,
        'clockOutImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _dataSource.updateClockOut(attendanceId, fields);

      // Re-read the updated record to return accurate data.
      final dateKey = DateUtil.toDateKey(now);
      final employeeId = attendanceId.split('_').first;
      final updated = await _dataSource.getTodayRecord(employeeId, dateKey);

      if (updated == null) {
        return const AppFailure(
          AttendanceFailure(
            'Data kehadiran tidak ditemukan setelah clock-out.',
            code: 'record-not-found',
          ),
        );
      }

      return AppSuccess(updated);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  @override
  Future<AppResult<AttendanceRecord?>> getTodayAttendance(
    String employeeId,
  ) async {
    try {
      final dateKey = DateUtil.toDateKey(DateTime.now());
      final record = await _dataSource.getTodayRecord(employeeId, dateKey);
      return AppSuccess(record);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Stream<AttendanceRecord?> watchTodayAttendance(String employeeId) {
    final dateKey = DateUtil.toDateKey(DateTime.now());
    return _dataSource.watchTodayRecord(employeeId, dateKey);
  }

  @override
  Future<AppResult<List<AttendanceRecord>>> getAttendanceByDateRange({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final records = await _dataSource.getByDateRange(
        employeeId,
        DateUtil.toDateKey(startDate),
        DateUtil.toDateKey(endDate),
      );
      return AppSuccess(records);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<Map<String, int>>> getWeeklyStats(String employeeId) async {
    try {
      final now = DateTime.now();

      // ISO week start: Monday.
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final records = await _dataSource.getByDateRange(
        employeeId,
        DateUtil.toDateKey(weekStart),
        DateUtil.toDateKey(weekEnd),
      );

      final stats = <String, int>{
        'hadir': 0,
        'telat': 0,
        'izin': 0,
        'alpha': 0,
      };

      for (final record in records) {
        final key = stats.containsKey(record.status) ? record.status : 'alpha';
        stats[key] = (stats[key] ?? 0) + 1;
      }

      return AppSuccess(stats);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  Failure _mapFailure(Object error) {
    if (error is FirebaseDataException) {
      return AttendanceFailure(error.message, code: error.code);
    }
    if (error is NetworkUnavailableException) {
      return NetworkFailure(error.message, code: error.code);
    }
    return UnknownFailure('Terjadi kesalahan kehadiran: $error');
  }
}
