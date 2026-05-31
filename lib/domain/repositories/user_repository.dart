import '../../core/utils/app_result.dart';
import '../entities/app_user.dart';

/// Contract for user profile operations.
abstract interface class UserRepository {
  /// Fetches the user profile from Firestore.
  Future<AppResult<AppUser>> getUserProfile(String userId);

  /// Updates user profile fields (name, phone).
  Future<AppResult<AppUser>> updateProfile({
    required String userId,
    required Map<String, dynamic> fields,
  });

  /// Changes the user's password after re-authentication.
  Future<AppResult<void>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  });
}
