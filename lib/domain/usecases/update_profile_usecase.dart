import '../../core/utils/app_result.dart';
import '../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/user_repository.dart';

/// Updates the user's profile information.
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final UserRepository _repository;

  Future<AppResult<AppUser>> call({
    required String userId,
    String? name,
    String? phone,
  }) async {
    // Validate inputs
    if (name != null && name.trim().length < 3) {
      return const AppFailure(DataFailure('Nama minimal 3 karakter.'));
    }
    if (phone != null && phone.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^(\+62|08)[0-9]{8,13}$');
      if (!phoneRegex.hasMatch(phone.trim())) {
        return const AppFailure(DataFailure('Format nomor HP tidak valid.'));
      }
    }

    final fields = <String, dynamic>{};
    if (name != null) fields['name'] = name.trim();
    if (phone != null) fields['phone'] = phone.trim();

    if (fields.isEmpty) {
      return const AppFailure(DataFailure('Tidak ada perubahan.'));
    }

    return _repository.updateProfile(userId: userId, fields: fields);
  }
}
