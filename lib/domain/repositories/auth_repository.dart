import '../../core/utils/app_result.dart';
import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser?> getCachedUser();

  Future<String?> getRememberedNik();

  Future<bool> getRememberMe();

  Future<AppResult<AppUser>> signInWithNik({
    required String nik,
    required String password,
    required bool rememberMe,
  });

  Future<AppResult<void>> sendPasswordReset(String nikOrEmail);

  Future<AppResult<void>> signOut();
}
