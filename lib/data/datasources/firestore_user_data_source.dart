import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/registration_request.dart';
import 'firebase_auth_data_source.dart';
import '../models/user_model.dart';

class FirestoreUserDataSource {
  FirestoreUserDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw UserNotFoundException(
          'Profil karyawan belum dibuat di Firestore.',
          code: 'user-profile-missing',
        );
      }
      final user = UserModel.fromFirestore(doc);
      if (!user.isActive) {
        throw AuthException('Akun tidak aktif. Hubungi admin HRD.');
      }
      return user;
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal membaca profil pengguna.',
        code: error.code,
      );
    }
  }

  Future<UserModel> createEmployeeProfile({
    required String userId,
    required RegistrationRequest request,
  }) async {
    try {
      final now = FieldValue.serverTimestamp();
      final isAdminNik = request.nik == '0123456789' || request.nik == '0000000000';
      final roleString = isAdminNik ? 'admin' : 'employee';
      final roleEnum = isAdminNik ? UserRole.admin : UserRole.employee;

      final data = <String, dynamic>{
        'userId': userId,
        'nik': request.nik,
        'name': request.name,
        'email': FirebaseAuthDataSource.nikToEmail(request.nik),
        'role': roleString,
        'department': request.department,
        'position': request.position,
        'phone': request.phone,
        'photoUrl': null,
        'shiftStart': '08:00',
        'shiftEnd': '17:00',
        'isActive': true,
        'createdAt': now,
        'updatedAt': now,
      };
      await _firestore.collection('users').doc(userId).set(data);

      return UserModel(
        userId: userId,
        nik: request.nik,
        name: request.name,
        email: FirebaseAuthDataSource.nikToEmail(request.nik),
        role: roleEnum,
        department: request.department,
        position: request.position,
        phone: request.phone,
        shiftStart: '08:00',
        shiftEnd: '17:00',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal membuat profil pengguna.',
        code: error.code,
      );
    }
  }

  /// Updates partial fields on a user profile document.
  Future<UserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(fields);
      // Re-fetch to get the updated data
      return getUserById(userId);
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal memperbarui profil.',
        code: error.code,
      );
    }
  }

  /// Streams real-time updates for a user document.
  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }
}
