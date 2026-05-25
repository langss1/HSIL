import '../../core/utils/app_result.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<void>> call() => _repository.signOut();
}
