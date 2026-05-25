import '../../core/utils/app_result.dart';
import '../entities/app_user.dart';
import '../entities/registration_request.dart';
import '../repositories/auth_repository.dart';

class RegisterEmployeeUseCase {
  const RegisterEmployeeUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<AppUser>> call(RegistrationRequest request) {
    return _repository.registerEmployee(request);
  }
}
