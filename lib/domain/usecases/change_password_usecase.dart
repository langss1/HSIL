import '../../core/utils/app_result.dart';
import '../../core/errors/failures.dart';
import '../repositories/user_repository.dart';

/// Changes the user's password after re-authentication.
class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final UserRepository _repository;

  Future<AppResult<void>> call({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.length < 6) {
      return const AppFailure(AuthFailure('Password baru minimal 6 karakter.'));
    }
    if (newPassword != confirmPassword) {
      return const AppFailure(AuthFailure('Konfirmasi password tidak cocok.'));
    }
    if (oldPassword == newPassword) {
      return const AppFailure(AuthFailure('Password baru harus berbeda dari password lama.'));
    }

    return _repository.changePassword(
      email: email,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
