import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../datasources/firestore_user_data_source.dart';

/// Concrete [UserRepository] backed by Firestore + Firebase Auth.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required FirestoreUserDataSource userDataSource,
    required FirebaseAuthDataSource authDataSource,
  }) : _userDataSource = userDataSource,
       _authDataSource = authDataSource;

  final FirestoreUserDataSource _userDataSource;
  final FirebaseAuthDataSource _authDataSource;

  @override
  Future<AppResult<AppUser>> getUserProfile(String userId) async {
    try {
      final user = await _userDataSource.getUserById(userId);
      return AppSuccess(user);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<AppUser>> updateProfile({
    required String userId,
    required Map<String, dynamic> fields,
  }) async {
    try {
      if (fields.containsKey('email')) {
        final newEmail = fields['email'] as String;
        
        // Cross-check if email is already in use by another user in Firestore
        final existing = await _userDataSource.getUserByEmail(newEmail);
        if (existing != null && existing.userId != userId) {
          return const AppFailure(DataFailure('Email ini sudah digunakan oleh akun lain.'));
        }
        
        // Synchronize with Firebase Auth
        await _authDataSource.updateEmail(newEmail);
      }

      final updated = await _userDataSource.updateUserProfile(userId, fields);
      return AppSuccess(updated);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<void>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _authDataSource.changePassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const AppSuccess(null);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  Failure _mapFailure(Object error) {
    if (error is AuthException) {
      return AuthFailure(error.message, code: error.code);
    }
    if (error is FirebaseDataException) {
      return DataFailure(error.message, code: error.code);
    }
    if (error is UserNotFoundException) {
      return DataFailure(error.message, code: error.code);
    }
    return UnknownFailure('Terjadi kesalahan: $error');
  }
}
