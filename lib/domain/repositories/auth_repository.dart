import '../../core/utils/app_result.dart';
import '../entities/app_user.dart';
import '../entities/registration_request.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser?> getCachedUser();

  Future<String?> getRememberedNik();

  Future<bool> getRememberMe();

  Future<AppResult<AppUser>> signIn({
    required String identifier,
    required String password,
    required bool rememberMe,
  });

  Future<AppResult<AppUser>> registerEmployee(RegistrationRequest request);

  Future<AppResult<void>> sendPasswordReset(String nikOrEmail);

  Future<AppResult<void>> signOut();

  Future<void> updateCachedUser(AppUser user);
}
