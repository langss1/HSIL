import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../models/leave_request_model.dart';

class FirestoreLeaveDataSource {
  FirestoreLeaveDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('leave_requests');

  Future<void> submitLeave(LeaveRequestModel model) async {
    try {
      await _collection.doc(model.id).set(model.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseDataException(e.message ?? 'Gagal menyimpan pengajuan izin', code: e.code);
    }
  }

  Future<List<LeaveRequestModel>> getAll() async {
    try {
      final snapshot = await _collection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(LeaveRequestModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw FirebaseDataException(e.message ?? 'Gagal membaca semua riwayat izin', code: e.code);
    }
  }

  Future<List<LeaveRequestModel>> getByEmployee(String employeeId) async {
    try {
      final snapshot = await _collection
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(LeaveRequestModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw FirebaseDataException(e.message ?? 'Gagal membaca riwayat izin', code: e.code);
    }
  }

  Future<List<LeaveRequestModel>> getPending() async {
    try {
      final snapshot = await _collection
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs.map(LeaveRequestModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw FirebaseDataException(e.message ?? 'Gagal membaca daftar pengajuan', code: e.code);
    }
  }

  Future<LeaveRequestModel> updateStatus(String id, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(id).update(fields);
      final updatedDoc = await _collection.doc(id).get();
      return LeaveRequestModel.fromFirestore(updatedDoc);
    } on FirebaseException catch (e) {
      throw FirebaseDataException(e.message ?? 'Gagal update status pengajuan', code: e.code);
    }
  }
}
