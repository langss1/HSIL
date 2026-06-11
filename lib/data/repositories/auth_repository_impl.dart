import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/network/retry_policy.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/registration_request.dart';
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
  Future<AppResult<AppUser>> signIn({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    final normalizedId = identifier.trim();
    final isEmail = normalizedId.contains('@') && normalizedId.contains('.');
    final isNik = RegExp(r'^\d{10}$').hasMatch(normalizedId);

    if (!isEmail && !isNik) {
      return const AppFailure(
        AuthFailure('Masukkan NIK (10 digit) atau email yang valid.', code: 'invalid-identifier'),
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
        if (cachedUser?.nik == normalizedId || cachedUser?.email == normalizedId) {
          return AppSuccess(cachedUser!);
        }
        return const AppFailure(
          NetworkFailure(
            'Offline login membutuhkan sesi yang sudah pernah tersimpan.',
            code: 'offline-login-blocked',
          ),
        );
      }

      String emailToLogin = normalizedId;
      String nikToRemember = normalizedId;

      if (isNik) {
        final userDoc = await _userDataSource.getUserByNik(normalizedId);
        if (userDoc == null) {
          return const AppFailure(AuthFailure('Akun dengan NIK ini tidak ditemukan.', code: 'user-not-found'));
        }
        emailToLogin = userDoc.email;
        nikToRemember = userDoc.nik;
      } else {
        final userDoc = await _userDataSource.getUserByEmail(normalizedId);
        if (userDoc == null) {
          return const AppFailure(AuthFailure('Akun dengan Email ini tidak ditemukan.', code: 'user-not-found'));
        }
        emailToLogin = userDoc.email;
        nikToRemember = userDoc.nik;
      }

      final credential = await _authDataSource.login(
        email: emailToLogin,
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
        nik: nikToRemember,
      );
      return AppSuccess(profile);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<AppUser>> registerEmployee(
    RegistrationRequest request,
  ) async {
    final normalizedNik = request.nik.trim();
    final normalizedName = request.name.trim();
    final normalizedEmail = request.email.trim();
    final normalizedDepartment = request.department.trim();
    final normalizedPosition = request.position.trim();

    if (!_isValidNik(normalizedNik)) {
      return const AppFailure(
        AuthFailure('NIK harus berisi 10 digit angka.', code: 'invalid-nik'),
      );
    }
    if (normalizedName.length < 3) {
      return const AppFailure(
        AuthFailure('Nama minimal 3 karakter.', code: 'invalid-name'),
      );
    }
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return const AppFailure(
        AuthFailure('Email tidak valid.', code: 'invalid-email'),
      );
    }
    if (request.password.length < 6) {
      return const AppFailure(
        AuthFailure('Password minimal 6 karakter.', code: 'weak-password'),
      );
    }
    if (normalizedDepartment.isEmpty || normalizedPosition.isEmpty) {
      return const AppFailure(
        AuthFailure('Departemen dan jabatan wajib diisi.'),
      );
    }
    if (_authDataSource == null || _userDataSource == null) {
      return const AppFailure(
        NetworkFailure(
          'Firebase belum terkonfigurasi. Masukkan config project sebelum register.',
          code: 'firebase-unavailable',
        ),
      );
    }

    try {
      final online = await _connectivityService.isOnline;
      if (!online) {
        return const AppFailure(
          NetworkFailure(
            'Register membutuhkan koneksi internet.',
            code: 'offline-register-blocked',
          ),
        );
      }

      final normalizedRequest = RegistrationRequest(
        nik: normalizedNik,
        name: normalizedName,
        email: normalizedEmail,
        password: request.password,
        department: normalizedDepartment,
        position: normalizedPosition,
        phone:
            request.phone == null || request.phone!.trim().isEmpty
                ? null
                : request.phone!.trim(),
      );
      final credential = await _authDataSource.register(
        email: normalizedEmail,
        password: request.password,
      );
      final firebaseUser = credential.user ?? _authDataSource.currentUser;
      if (firebaseUser == null) {
        return const AppFailure(
          AuthFailure('Firebase tidak mengembalikan sesi pengguna.'),
        );
      }

      final profile = await _userDataSource.createEmployeeProfile(
        userId: firebaseUser.uid,
        request: normalizedRequest,
      );
      await _localSessionDataSource.cacheUser(profile);
      await _localSessionDataSource.saveRememberMe(
        rememberMe: true,
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
    final userDataSource = _userDataSource;
    if (authDataSource == null || userDataSource == null) {
      return const AppFailure(NetworkFailure('Firebase belum terkonfigurasi.'));
    }

    try {
      final normalizedId = nikOrEmail.trim();
      final isEmail = normalizedId.contains('@');
      String emailToReset = normalizedId;
      
      if (!isEmail) {
        final userDoc = await userDataSource.getUserByNik(normalizedId);
        if (userDoc == null) {
           return const AppFailure(AuthFailure('Akun dengan NIK ini tidak ditemukan.', code: 'user-not-found'));
        }
        emailToReset = userDoc.email;
      } else {
        final userDoc = await userDataSource.getUserByEmail(normalizedId);
        if (userDoc == null) {
           return const AppFailure(AuthFailure('Akun dengan email ini tidak ditemukan.', code: 'user-not-found'));
        }
        emailToReset = userDoc.email;
      }

      await authDataSource.sendPasswordReset(emailToReset);
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
