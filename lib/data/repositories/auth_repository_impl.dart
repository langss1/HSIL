import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/network/retry_policy.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../datasources/firestore_user_data_source.dart';
import '../datasources/local_session_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuthDataSource? authDataSource,
    required FirestoreUserDataSource? userDataSource,
    required LocalSessionDataSource localSessionDataSource,
    required ConnectivityService connectivityService,
    required RetryPolicy retryPolicy,
  }) : _authDataSource = authDataSource,
       _userDataSource = userDataSource,
       _localSessionDataSource = localSessionDataSource,
       _connectivityService = connectivityService,
       _retryPolicy = retryPolicy;

  final FirebaseAuthDataSource? _authDataSource;
  final FirestoreUserDataSource? _userDataSource;
  final LocalSessionDataSource _localSessionDataSource;
  final ConnectivityService _connectivityService;
  final RetryPolicy _retryPolicy;

  @override
  Stream<AppUser?> authStateChanges() {
    final authDataSource = _authDataSource;
    if (authDataSource == null) {
      return Stream<AppUser?>.fromFuture(getCachedUser());
    }

    return authDataSource.authStateChanges
        .asyncMap((firebaseUser) async {
          if (firebaseUser == null) {
            return null;
          }
          return _loadUserProfile(firebaseUser.uid);
        })
        .handleError((Object error) async {
          return getCachedUser();
        });
  }

  @override
  Future<AppUser?> getCachedUser() => _localSessionDataSource.getCachedUser();

  @override
  Future<bool> getRememberMe() => _localSessionDataSource.getRememberMe();

  @override
  Future<String?> getRememberedNik() =>
      _localSessionDataSource.getRememberedNik();

  @override
  Future<AppResult<AppUser>> signInWithNik({
    required String nik,
    required String password,
    required bool rememberMe,
  }) async {
    final normalizedNik = nik.trim();
    if (!_isValidNik(normalizedNik)) {
      return const AppFailure(
        AuthFailure('NIK harus berisi 10 digit angka.', code: 'invalid-nik'),
      );
    }
    if (password.length < 6) {
      return const AppFailure(
        AuthFailure('Password minimal 6 karakter.', code: 'weak-password'),
      );
    }

    if (_authDataSource == null || _userDataSource == null) {
      return const AppFailure(
        NetworkFailure(
          'Firebase belum terkonfigurasi. Masukkan config project sebelum login.',
          code: 'firebase-unavailable',
        ),
      );
    }

    try {
      final online = await _connectivityService.isOnline;
      if (!online) {
        final cachedUser = await _localSessionDataSource.getCachedUser();
        if (cachedUser?.nik == normalizedNik) {
          return AppSuccess(cachedUser!);
        }
        return const AppFailure(
          NetworkFailure(
            'Offline login membutuhkan sesi yang sudah pernah tersimpan.',
            code: 'offline-login-blocked',
          ),
        );
      }

      final credential = await _authDataSource.loginWithNik(
        nik: normalizedNik,
        password: password,
      );
      final firebaseUser = credential.user ?? _authDataSource.currentUser;
      if (firebaseUser == null) {
        return const AppFailure(
          AuthFailure('Firebase tidak mengembalikan sesi pengguna.'),
        );
      }

      final profile = await _loadUserProfile(firebaseUser.uid);
      await _localSessionDataSource.saveRememberMe(
        rememberMe: rememberMe,
        nik: normalizedNik,
      );
      return AppSuccess(profile);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<void>> sendPasswordReset(String nikOrEmail) async {
    final authDataSource = _authDataSource;
    if (authDataSource == null) {
      return const AppFailure(NetworkFailure('Firebase belum terkonfigurasi.'));
    }

    try {
      await authDataSource.sendPasswordReset(nikOrEmail.trim());
      return const AppSuccess(null);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<void>> signOut() async {
    try {
      await _authDataSource?.logout();
      await _localSessionDataSource.clearSession();
      return const AppSuccess(null);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  Future<UserModel> _loadUserProfile(String userId) async {
    final userDataSource = _userDataSource;
    if (userDataSource == null) {
      throw const NetworkUnavailableException('Firebase belum siap.');
    }
    final profile = await _retryPolicy.run(
      () => userDataSource.getUserById(userId),
    );
    await _localSessionDataSource.cacheUser(profile);
    return profile;
  }

  bool _isValidNik(String value) => RegExp(r'^\d{10}$').hasMatch(value);

  Failure _mapFailure(Object error) {
    if (error is AuthException) {
      return AuthFailure(error.message, code: error.code);
    }
    if (error is UserNotFoundException) {
      return DataFailure(error.message, code: error.code);
    }
    if (error is FirebaseDataException) {
      return DataFailure(error.message, code: error.code);
    }
    if (error is FirebaseAuthException) {
      return AuthFailure(error.message ?? 'Login gagal.', code: error.code);
    }
    if (error is NetworkUnavailableException) {
      return NetworkFailure(error.message, code: error.code);
    }
    return UnknownFailure('Terjadi kesalahan tidak terduga: $error');
  }
}
