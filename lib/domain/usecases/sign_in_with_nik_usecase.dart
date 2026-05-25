import '../../core/utils/app_result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithNikUseCase {
  const SignInWithNikUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<AppUser>> call({
    required String nik,
    required String password,
    required bool rememberMe,
  }) {
    return _repository.signInWithNik(
      nik: nik,
      password: password,
      rememberMe: rememberMe,
    );
  }
}
