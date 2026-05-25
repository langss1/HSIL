import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> loginWithNik({
    required String nik,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: nikToEmail(nik),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthMessage(error), code: error.code);
    }
  }

  Future<void> sendPasswordReset(String nikOrEmail) async {
    final email =
        nikOrEmail.contains('@') ? nikOrEmail : nikToEmail(nikOrEmail);
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthMessage(error), code: error.code);
    }
  }

  Future<void> logout() async => _auth.signOut();

  static String nikToEmail(String nik) {
    return '${nik.trim()}@${AppConstants.nikEmailDomain}';
  }

  String _mapAuthMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Format NIK tidak valid.',
      'user-not-found' => 'NIK tidak ditemukan.',
      'wrong-password' || 'invalid-credential' => 'Password salah.',
      'user-disabled' => 'Akun dinonaktifkan oleh admin.',
      'network-request-failed' => 'Koneksi bermasalah. Coba lagi sebentar.',
      'too-many-requests' => 'Terlalu banyak percobaan. Tunggu beberapa menit.',
      _ => error.message ?? 'Login gagal. Silakan coba lagi.',
    };
  }
}
