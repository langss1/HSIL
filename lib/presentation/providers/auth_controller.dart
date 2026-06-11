import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/di/app_dependencies.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/registration_request.dart';

enum AuthStatus {
  bootstrapping,
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthController extends ChangeNotifier {
  AuthController(this._dependencies);

  final AppDependencies _dependencies;
  StreamSubscription<AppUser?>? _authSubscription;

  AuthStatus _status = AuthStatus.bootstrapping;
  AppUser? _user;
  String? _errorMessage;
  String? _infoMessage;
  String? _rememberedNik;
  bool _rememberMe = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  String? get rememberedNik => _rememberedNik;
  bool get rememberMe => _rememberMe;
  bool get isBusy => _status == AuthStatus.authenticating;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isFirebaseReady => _dependencies.firebase.isReady;
  String? get firebaseMessage => _dependencies.firebase.message;

  Future<void> initialize() async {
    // Tahan splash screen selama minimal 2.5 detik agar animasinya terlihat bagus
    final splashTimer = Future.delayed(const Duration(milliseconds: 2500));

    _rememberMe = await _dependencies.authRepository.getRememberMe();
    _rememberedNik = await _dependencies.authRepository.getRememberedNik();
    _infoMessage = _dependencies.firebase.message;
    notifyListeners();

    // Tunggu animasi splash screen selesai sebelum menampilkan layar login/utama
    await splashTimer;

    _authSubscription = _dependencies.observeAuthState().listen(
      (user) {
        _user = user;
        _status =
            user == null
                ? AuthStatus.unauthenticated
                : AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Sesi tidak dapat dimuat: $error';
        notifyListeners();
      },
    );
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  Future<void> signIn({required String identifier, required String password}) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    final result = await _dependencies.signInWithNik(
      identifier: identifier,
      password: password,
      rememberMe: _rememberMe,
    );

    result.when(
      success: (user) {
        _user = user;
        _rememberedNik = _rememberMe ? user.nik : null;
        _status = AuthStatus.authenticated;
      },
      failure: (failure) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = failure.message;
      },
    );
    notifyListeners();
  }

  Future<void> registerEmployee(RegistrationRequest request) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    final result = await _dependencies.registerEmployee(request);
    result.when(
      success: (user) {
        _user = user;
        _rememberMe = true;
        _rememberedNik = user.nik;
        _status = AuthStatus.authenticated;
        _infoMessage = 'Akun berhasil dibuat.';
      },
      failure: (failure) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = failure.message;
      },
    );
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String nikOrEmail) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    final result = await _dependencies.sendPasswordReset(nikOrEmail);
    var sent = false;
    result.when(
      success: (_) {
        sent = true;
        _infoMessage = 'Link reset password sudah dikirim.';
      },
      failure: (failure) {
        _errorMessage = failure.message;
      },
    );
    _status =
        _user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
    return sent;
  }

  Future<void> signOut() async {
    final result = await _dependencies.signOut();
    result.when(
      success: (_) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      },
      failure: (failure) {
        _errorMessage = failure.message;
      },
    );
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    _dependencies.notificationService.dispose();
    super.dispose();
  }
}
