import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/exceptions.dart';
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
}
