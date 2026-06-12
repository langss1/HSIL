import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/date_util.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../../domain/entities/app_user.dart';

class FirestoreAdminDataSource {
  const FirestoreAdminDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<UserModel>> getAllEmployees() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw DataFailure(e.message ?? 'Failed to get employees');
    } catch (e) {
      throw DataFailure(e.toString());
    }
  }

  Future<List<AttendanceModel>> getTodayAttendance() async {
    try {
      final today = DateUtil.toDateKey(DateTime.now());
      final snapshot = await _firestore
          .collection('attendance')
          .where('date', isEqualTo: today)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AttendanceModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw DataFailure(e.message ?? 'Failed to get today attendance');
    } catch (e) {
      throw DataFailure(e.toString());
    }
  }

  Future<List<AttendanceModel>> getEmployeeAttendance(
      String employeeId, DateTime startDate, DateTime endDate) async {
    try {
      final start = DateUtil.toDateKey(startDate);
      final end = DateUtil.toDateKey(endDate);

      final snapshot = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      final allRecords = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AttendanceModel.fromJson(data);
      }).toList();

      final filteredRecords = allRecords.where((record) {
        return record.date.compareTo(start) >= 0 && record.date.compareTo(end) <= 0;
      }).toList();

      filteredRecords.sort((a, b) => b.date.compareTo(a.date));

      return filteredRecords;
    } on FirebaseException catch (e) {
      throw DataFailure(e.message ?? 'Failed to get employee attendance');
    } catch (e) {
      throw DataFailure(e.toString());
    }
  }

  Future<List<AttendanceModel>> getAttendanceRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final start = DateUtil.toDateKey(startDate);
      final end = DateUtil.toDateKey(endDate);

      final snapshot = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AttendanceModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw DataFailure(e.message ?? 'Failed to get attendance range');
    } catch (e) {
      throw DataFailure(e.toString());
    }
  }

  Future<void> updateEmployeeRole(String employeeId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(employeeId).update({
        'role': newRole.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      throw const DataFailure(
        'Koneksi timeout. Silakan periksa jaringan internet Anda atau pastikan Anda masuk menggunakan akun dengan hak akses Admin.',
        code: 'timeout',
      );
    } on FirebaseException catch (e) {
      throw DataFailure(e.message ?? 'Failed to update employee role');
    } catch (e) {
      throw DataFailure(e.toString());
    }
  }

  Future<void> deleteEmployeeDoc(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete().timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      throw const DataFailure(
        'Koneksi timeout saat mencoba menghapus data.',
        code: 'timeout',
      );
    } on FirebaseException catch (e) {
      throw DataFailure(e.message ?? 'Failed to delete employee');
    } catch (e) {
      throw DataFailure(e.toString());
    }
  }
}
