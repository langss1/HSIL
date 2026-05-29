import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/firebase_auth_data_source.dart';
import '../../data/datasources/firestore_attendance_data_source.dart';
import '../../data/datasources/firestore_user_data_source.dart';
import '../../data/datasources/geolocator_data_source.dart';
import '../../data/datasources/local_session_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/clock_in_usecase.dart';
import '../../domain/usecases/clock_out_usecase.dart';
import '../../domain/usecases/get_weekly_stats_usecase.dart';
import '../../domain/usecases/observe_auth_state_usecase.dart';
import '../../domain/usecases/register_employee_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_with_nik_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/validate_gps_usecase.dart';
import '../network/connectivity_service.dart';
import '../network/retry_policy.dart';
import '../services/firebase_bootstrap_service.dart';
import '../services/notification_service.dart';

class AppDependencies {
  const AppDependencies({
    required this.firebase,
    required this.authRepository,
    required this.locationRepository,
    required this.attendanceRepository,
    required this.observeAuthState,
    required this.signInWithNik,
    required this.registerEmployee,
    required this.sendPasswordReset,
    required this.signOut,
    required this.validateGPS,
    required this.clockIn,
    required this.clockOut,
    required this.getWeeklyStats,
    required this.notificationService,
  });

  final FirebaseBootstrapResult firebase;
  final AuthRepository authRepository;
  final LocationRepository locationRepository;
  final AttendanceRepository attendanceRepository;
  final ObserveAuthStateUseCase observeAuthState;
  final SignInWithNikUseCase signInWithNik;
  final RegisterEmployeeUseCase registerEmployee;
  final SendPasswordResetUseCase sendPasswordReset;
  final SignOutUseCase signOut;
  final ValidateGPSUseCase validateGPS;
  final ClockInUseCase clockIn;
  final ClockOutUseCase clockOut;
  final GetWeeklyStatsUseCase getWeeklyStats;
  final NotificationService notificationService;

  static Future<AppDependencies> create() async {
    final preferences = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final firebase = await const FirebaseBootstrapService().initialize();

    final localSessionDataSource = LocalSessionDataSource(
      preferences: preferences,
      secureStorage: secureStorage,
    );
    final authRepository = AuthRepositoryImpl(
      authDataSource:
          firebase.isReady
              ? FirebaseAuthDataSource(FirebaseAuth.instance)
              : null,
      userDataSource:
          firebase.isReady
              ? FirestoreUserDataSource(FirebaseFirestore.instance)
              : null,
      localSessionDataSource: localSessionDataSource,
      connectivityService: ConnectivityService(Connectivity()),
      retryPolicy: const RetryPolicy(),
    );
    
    final locationRepository = LocationRepositoryImpl(
      geolocatorDataSource: const GeolocatorDataSource(),
    );
    
    // Create an instance even if Firebase is somehow not ready, to satisfy DI.
    // It will throw inside the methods if used, but shouldn't happen.
    final attendanceDataSource = FirestoreAttendanceDataSource(FirebaseFirestore.instance);
    final attendanceRepository = AttendanceRepositoryImpl(
      attendanceDataSource: attendanceDataSource,
    );
    
    final notificationService = NotificationService(
      firebase.isReady ? FirebaseMessaging.instance : null,
    );

    return AppDependencies(
      firebase: firebase,
      authRepository: authRepository,
      locationRepository: locationRepository,
      attendanceRepository: attendanceRepository,
      observeAuthState: ObserveAuthStateUseCase(authRepository),
      signInWithNik: SignInWithNikUseCase(authRepository),
      registerEmployee: RegisterEmployeeUseCase(authRepository),
      sendPasswordReset: SendPasswordResetUseCase(authRepository),
      signOut: SignOutUseCase(authRepository),
      validateGPS: ValidateGPSUseCase(locationRepository),
      clockIn: ClockInUseCase(attendanceRepository),
      clockOut: ClockOutUseCase(attendanceRepository),
      getWeeklyStats: GetWeeklyStatsUseCase(attendanceRepository),
      notificationService: notificationService,
    );
  }
}
