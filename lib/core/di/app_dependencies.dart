import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_result.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../data/datasources/firebase_auth_data_source.dart';
import '../../data/datasources/firestore_attendance_data_source.dart';
import '../../data/datasources/firestore_notification_data_source.dart';
import '../../data/datasources/firestore_user_data_source.dart';
import '../../data/datasources/geolocator_data_source.dart';
import '../../data/datasources/local_session_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/datasources/firestore_admin_data_source.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/clock_in_usecase.dart';
import '../../domain/usecases/clock_out_usecase.dart';
import '../../domain/usecases/get_attendance_history_usecase.dart';
import '../../domain/usecases/get_weekly_stats_usecase.dart';
import '../../domain/usecases/observe_auth_state_usecase.dart';
import '../../domain/usecases/register_employee_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_with_nik_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/validate_gps_usecase.dart';
import '../../data/datasources/firestore_leave_data_source.dart';
import '../../data/repositories/leave_repository_impl.dart';
import '../../domain/repositories/leave_repository.dart';
import '../../domain/usecases/submit_leave_usecase.dart';
import '../../domain/usecases/get_my_leaves_usecase.dart';
import '../../domain/usecases/get_pending_leaves_usecase.dart';
import '../../domain/usecases/get_all_leaves_usecase.dart';
import '../../domain/usecases/review_leave_usecase.dart';
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
    required this.userRepository,
    required this.notificationRepository,
    required this.observeAuthState,
    required this.signInWithNik,
    required this.registerEmployee,
    required this.sendPasswordReset,
    required this.signOut,
    required this.validateGPS,
    required this.clockIn,
    required this.clockOut,
    required this.getWeeklyStats,
    required this.getAttendanceHistory,
    required this.updateProfile,
    required this.changePassword,
    required this.notificationService,
    required this.adminRepository,
    required this.leaveRepository,
    required this.submitLeave,
    required this.getMyLeaves,
    required this.getPendingLeaves,
    required this.getAllLeaves,
    required this.reviewLeave,
  });

  final FirebaseBootstrapResult firebase;
  final AuthRepository authRepository;
  final LocationRepository locationRepository;
  final AttendanceRepository attendanceRepository;
  final UserRepository userRepository;
  final NotificationRepository notificationRepository;
  final ObserveAuthStateUseCase observeAuthState;
  final SignInWithNikUseCase signInWithNik;
  final RegisterEmployeeUseCase registerEmployee;
  final SendPasswordResetUseCase sendPasswordReset;
  final SignOutUseCase signOut;
  final ValidateGPSUseCase validateGPS;
  final ClockInUseCase clockIn;
  final ClockOutUseCase clockOut;
  final GetWeeklyStatsUseCase getWeeklyStats;
  final GetAttendanceHistoryUseCase getAttendanceHistory;
  final UpdateProfileUseCase updateProfile;
  final ChangePasswordUseCase changePassword;
  final NotificationService notificationService;
  final AdminRepository adminRepository;
  final LeaveRepository leaveRepository;
  final SubmitLeaveUseCase submitLeave;
  final GetMyLeavesUseCase getMyLeaves;
  final GetPendingLeavesUseCase getPendingLeaves;
  final GetAllLeavesUseCase getAllLeaves;
  final ReviewLeaveUseCase reviewLeave;

  static Future<AppDependencies> create() async {
    final preferences = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final firebase = await const FirebaseBootstrapService().initialize();

    final firestore = FirebaseFirestore.instance;
    final authDataSource = firebase.isReady
        ? FirebaseAuthDataSource(FirebaseAuth.instance)
        : null;
    final userDataSource = firebase.isReady
        ? FirestoreUserDataSource(firestore)
        : null;

    final localSessionDataSource = LocalSessionDataSource(
      preferences: preferences,
      secureStorage: secureStorage,
    );
    final authRepository = AuthRepositoryImpl(
      authDataSource: authDataSource,
      userDataSource: userDataSource,
      localSessionDataSource: localSessionDataSource,
      connectivityService: ConnectivityService(Connectivity()),
      retryPolicy: const RetryPolicy(),
    );
    
    final locationRepository = LocationRepositoryImpl(
      geolocatorDataSource: const GeolocatorDataSource(),
    );
    
    final attendanceDataSource = FirestoreAttendanceDataSource(firestore);
    final attendanceRepository = AttendanceRepositoryImpl(
      attendanceDataSource: attendanceDataSource,
    );

    final notificationDataSource = FirestoreNotificationDataSource(firestore);
    final notificationRepository = NotificationRepositoryImpl(
      dataSource: notificationDataSource,
    );

    final userRepository = (authDataSource != null && userDataSource != null)
        ? UserRepositoryImpl(
            userDataSource: userDataSource,
            authDataSource: authDataSource,
          )
        : null;

    final notificationService = NotificationService(
      firebase.isReady ? FirebaseMessaging.instance : null,
      notificationDataSource: firebase.isReady ? notificationDataSource : null,
    );

    final adminDataSource = FirestoreAdminDataSource(firestore);
    final adminRepository = AdminRepositoryImpl(adminDataSource: adminDataSource);

    final leaveDataSource = FirestoreLeaveDataSource(firestore);
    final leaveRepository = LeaveRepositoryImpl(
      leaveDataSource: leaveDataSource,
      attendanceDataSource: attendanceDataSource,
    );

    return AppDependencies(
      firebase: firebase,
      authRepository: authRepository,
      locationRepository: locationRepository,
      attendanceRepository: attendanceRepository,
      userRepository: userRepository ?? _DummyUserRepository(),
      notificationRepository: notificationRepository,
      observeAuthState: ObserveAuthStateUseCase(authRepository),
      signInWithNik: SignInWithNikUseCase(authRepository),
      registerEmployee: RegisterEmployeeUseCase(authRepository),
      sendPasswordReset: SendPasswordResetUseCase(authRepository),
      signOut: SignOutUseCase(authRepository),
      validateGPS: ValidateGPSUseCase(locationRepository),
      clockIn: ClockInUseCase(attendanceRepository),
      clockOut: ClockOutUseCase(attendanceRepository),
      getWeeklyStats: GetWeeklyStatsUseCase(attendanceRepository),
      getAttendanceHistory: GetAttendanceHistoryUseCase(attendanceRepository),
      updateProfile: UpdateProfileUseCase(userRepository ?? _DummyUserRepository()),
      changePassword: ChangePasswordUseCase(userRepository ?? _DummyUserRepository()),
      notificationService: notificationService,
      adminRepository: adminRepository,
      leaveRepository: leaveRepository,
      submitLeave: SubmitLeaveUseCase(leaveRepository),
      getMyLeaves: GetMyLeavesUseCase(leaveRepository),
      getPendingLeaves: GetPendingLeavesUseCase(leaveRepository),
      getAllLeaves: GetAllLeavesUseCase(leaveRepository),
      reviewLeave: ReviewLeaveUseCase(leaveRepository),
    );
  }
}

/// Fallback when Firebase is unavailable.
class _DummyUserRepository implements UserRepository {
  @override
  Future<AppResult<AppUser>> getUserProfile(String userId) async =>
      const AppFailure(DataFailure('Firebase tidak tersedia.'));
  @override
  Future<AppResult<AppUser>> updateProfile({
    required String userId,
    required Map<String, dynamic> fields,
  }) async => const AppFailure(DataFailure('Firebase tidak tersedia.'));
  @override
  Future<AppResult<void>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async => const AppFailure(DataFailure('Firebase tidak tersedia.'));
}
