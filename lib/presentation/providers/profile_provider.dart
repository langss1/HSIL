import 'package:flutter/foundation.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required UpdateProfileUseCase updateProfile,
    required ChangePasswordUseCase changePassword,
  }) : _updateProfile = updateProfile,
       _changePassword = changePassword;

  final UpdateProfileUseCase _updateProfile;
  final ChangePasswordUseCase _changePassword;

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? phone,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _updateProfile(
      userId: userId,
      name: name,
      phone: phone,
    );

    return result.when(
      success: (user) {
        _successMessage = 'Profil berhasil diperbarui.';
        _isSaving = false;
        notifyListeners();
        return true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _isSaving = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _changePassword(
      email: email,
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    return result.when(
      success: (_) {
        _successMessage = 'Password berhasil diubah.';
        _isSaving = false;
        notifyListeners();
        return true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _isSaving = false;
        notifyListeners();
        return false;
      },
    );
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
