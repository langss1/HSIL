import '../../core/utils/app_result.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<void>> call(String nikOrEmail) {
    return _repository.sendPasswordReset(nikOrEmail);
  }
}
