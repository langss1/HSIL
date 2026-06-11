import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/exceptions.dart';
import '../models/attendance_model.dart';

/// Remote data source for the `attendance` Firestore collection.
///
/// All methods throw [FirebaseDataException] when a Firestore operation fails,
/// keeping error translation consistent with [FirestoreUserDataSource].
class FirestoreAttendanceDataSource {
  FirestoreAttendanceDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Reference to the root `attendance` collection.
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('attendance');

  /// Persists a clock-in record using a deterministic document ID.
  ///
  /// The [model]'s `id` field is used as the document key so that
  /// duplicate clock-ins for the same employee + date overwrite cleanly.
  Future<void> saveClockIn(AttendanceModel model) async {
    try {
      await _collection.doc(model.id).set(model.toJson());
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal menyimpan data clock-in.',
        code: error.code,
      );
    }
  }

  /// Creates an attendance record for approved leave (izin/sakit).
  /// Used by LeaveRepository when admin approves a leave request.
  Future<void> saveLeaveAttendance(AttendanceModel model) async {
    try {
      await _collection.doc(model.id).set(model.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal menyimpan data absensi izin.',
        code: error.code,
      );
    }
  }

  /// Updates an existing attendance record with clock-out data.
  ///
  /// [fields] should contain the clock-out timestamp, GPS coordinates,
  /// distance, and an `updatedAt` server timestamp.
  Future<void> updateClockOut(
    String recordId,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _collection.doc(recordId).update(fields);
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal menyimpan data clock-out.',
        code: error.code,
      );
    }
  }

  /// Fetches today's attendance record for [employeeId] matching [date].
  ///
  /// Returns `null` when no matching document exists.
  Future<AttendanceModel?> getTodayRecord(
    String employeeId,
    String date,
  ) async {
    try {
      final snapshot =
          await _collection
              .where('employeeId', isEqualTo: employeeId)
              .where('date', isEqualTo: date)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;
      return AttendanceModel.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal membaca data kehadiran hari ini.',
        code: error.code,
      );
    }
  }

  /// Streams real-time updates for today's attendance record.
  ///
  /// Emits `null` when no record exists for the given [employeeId] + [date].
  Stream<AttendanceModel?> watchTodayRecord(
    String employeeId,
    String date,
  ) {
    return _collection
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isEqualTo: date)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return AttendanceModel.fromFirestore(snapshot.docs.first);
        });
  }

  /// Fetches attendance records for [employeeId] between [startDate] and
  /// [endDate] (inclusive), sorted by date ascending.
  ///
  /// Both date parameters should be in `yyyy-MM-dd` format.
  Future<List<AttendanceModel>> getByDateRange(
    String employeeId,
    String startDate,
    String endDate,
  ) async {
    try {
      final snapshot =
          await _collection
              .where('employeeId', isEqualTo: employeeId)
              .where('date', isGreaterThanOrEqualTo: startDate)
              .where('date', isLessThanOrEqualTo: endDate)
              .orderBy('date')
              .get();

      return snapshot.docs
          .map(AttendanceModel.fromFirestore)
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal membaca riwayat kehadiran.',
        code: error.code,
      );
    }
  }

  /// Fetches a single attendance record by document ID.
  Future<AttendanceModel?> getRecordById(String recordId) async {
    try {
      final doc = await _collection.doc(recordId).get();
      if (!doc.exists) return null;
      return AttendanceModel.fromFirestore(doc);
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal membaca detail kehadiran.',
        code: error.code,
      );
    }
  }
}
