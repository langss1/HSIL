import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/attendance_record.dart';

/// Firestore-aware data model for [AttendanceRecord].
///
/// Handles serialisation / deserialisation of Firestore [Timestamp] fields
/// and provides convenience factories for clock-in creation.
class AttendanceModel extends AttendanceRecord {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.date,
    required super.status,
    required super.gpsStatus,
    super.clockIn,
    super.clockOut,
    super.clockInLat,
    super.clockInLng,
    super.clockOutLat,
    super.clockOutLng,
    super.clockInDistance,
    super.clockOutDistance,
    super.createdAt,
    super.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

  /// Creates an [AttendanceModel] from a Firestore [DocumentSnapshot].
  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AttendanceModel.fromJson({...data, 'id': data['id'] ?? doc.id});
  }

  /// Creates an [AttendanceModel] from a raw JSON map.
  ///
  /// Handles `Timestamp`, `String`, and `DateTime` values for date fields.
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: (json['id'] as String?) ?? '',
      employeeId: (json['employeeId'] as String?) ?? '',
      employeeName: (json['employeeName'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      clockIn: _dateFromJson(json['clockIn']),
      clockOut: _dateFromJson(json['clockOut']),
      clockInLat: (json['clockInLat'] as num?)?.toDouble(),
      clockInLng: (json['clockInLng'] as num?)?.toDouble(),
      clockOutLat: (json['clockOutLat'] as num?)?.toDouble(),
      clockOutLng: (json['clockOutLng'] as num?)?.toDouble(),
      clockInDistance: (json['clockInDistance'] as num?)?.toDouble(),
      clockOutDistance: (json['clockOutDistance'] as num?)?.toDouble(),
      status: (json['status'] as String?) ?? 'alpha',
      gpsStatus: (json['gpsStatus'] as String?) ?? 'unknown',
      createdAt: _dateFromJson(json['createdAt']),
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  /// Creates a new clock-in record with automatic status determination.
  ///
  /// The [status] is resolved to `'hadir'` when [clockIn] is at or before
  /// the employee's [shiftStart] time, and `'telat'` otherwise.
  factory AttendanceModel.forClockIn({
    required String employeeId,
    required String employeeName,
    required String date,
    required DateTime clockIn,
    required double latitude,
    required double longitude,
    required double distanceMeters,
    required bool isInArea,
    required String shiftStart,
  }) {
    final id = _generateId(employeeId, date);
    final status = _resolveStatus(clockIn, shiftStart);
    final gpsStatus = isInArea ? 'IN_AREA' : 'OUTSIDE_AREA';

    return AttendanceModel(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      date: date,
      clockIn: clockIn,
      clockInLat: latitude,
      clockInLng: longitude,
      clockInDistance: distanceMeters,
      status: status,
      gpsStatus: gpsStatus,
      createdAt: clockIn,
      updatedAt: clockIn,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  /// Serialises this model to a Firestore-compatible JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date,
      'clockIn': clockIn,
      'clockOut': clockOut,
      'clockInLat': clockInLat,
      'clockInLng': clockInLng,
      'clockOutLat': clockOutLat,
      'clockOutLng': clockOutLng,
      'clockInDistance': clockInDistance,
      'clockOutDistance': clockOutDistance,
      'status': status,
      'gpsStatus': gpsStatus,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Converts a Firestore value (Timestamp, String, or DateTime) to [DateTime].
  static DateTime? _dateFromJson(Object? value) {
    return switch (value) {
      Timestamp timestamp => timestamp.toDate(),
      String raw => DateTime.tryParse(raw),
      DateTime date => date,
      _ => null,
    };
  }

  /// Generates a deterministic document ID: `{employeeId}_{date}`.
  static String _generateId(String employeeId, String date) =>
      '${employeeId}_$date';

  /// Determines attendance status by comparing clock-in time against shift.
  ///
  /// Returns `'hadir'` if [clockIn] is at or before the [shiftStart] time,
  /// otherwise returns `'telat'`.
  static String _resolveStatus(DateTime clockIn, String shiftStart) {
    final parts = shiftStart.split(':');
    if (parts.length < 2) return 'hadir';

    final shiftHour = int.tryParse(parts[0]) ?? 8;
    final shiftMinute = int.tryParse(parts[1]) ?? 0;
    final shiftDateTime = DateTime(
      clockIn.year,
      clockIn.month,
      clockIn.day,
      shiftHour,
      shiftMinute,
    );

    return clockIn.isAfter(shiftDateTime) ? 'telat' : 'hadir';
  }
}
