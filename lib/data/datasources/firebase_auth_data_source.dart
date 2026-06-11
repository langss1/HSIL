import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthMessage(error), code: error.code);
    }
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthMessage(error), code: error.code);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthMessage(error), code: error.code);
    }
  }

  Future<void> logout() async => _auth.signOut();

  /// Re-authenticates the user and updates their password.
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('Sesi tidak ditemukan. Silakan login kembali.');
      }
      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthMessage(error), code: error.code);
    }
  }

  /// Updates the user's email address.
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('Sesi tidak ditemukan. Silakan login kembali.');
      }
      // ignore: deprecated_member_use
      await user.updateEmail(newEmail);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        throw AuthException(
          'Demi keamanan, Anda harus logout dan login ulang sebelum dapat mengubah email.',
          code: error.code,
        );
      }
      throw AuthException(_mapAuthMessage(error), code: error.code);
    }
  }

  String _mapAuthMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Format NIK tidak valid.',
      'email-already-in-use' => 'NIK sudah terdaftar.',
      'user-not-found' => 'NIK tidak ditemukan.',
      'weak-password' => 'Password terlalu lemah.',
      'wrong-password' || 'invalid-credential' => 'Password salah.',
      'user-disabled' => 'Akun dinonaktifkan oleh admin.',
      'network-request-failed' => 'Koneksi bermasalah. Coba lagi sebentar.',
      'too-many-requests' => 'Terlalu banyak percobaan. Tunggu beberapa menit.',
      _ => error.message ?? 'Login gagal. Silakan coba lagi.',
    };
  }
}
