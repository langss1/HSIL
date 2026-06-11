import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'core/di/app_dependencies.dart';
import 'core/themes/app_theme.dart';
import 'presentation/app_router.dart';
import 'presentation/providers/attendance_provider.dart';
import 'presentation/providers/auth_controller.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/admin_provider.dart';
import 'presentation/providers/leave_provider.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/splash_screen.dart';

import 'core/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initialize();
  await initializeDateFormatting('id_ID', null);
  final dependencies = await AppDependencies.create();
  runApp(FactoryAttendanceApp(dependencies: dependencies));
}

class FactoryAttendanceApp extends StatelessWidget {
  const FactoryAttendanceApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: dependencies),
        ChangeNotifierProvider(
          create: (_) => AuthController(dependencies)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(
            locationRepository: dependencies.locationRepository,
            validateGPSUseCase: dependencies.validateGPS,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(
            clockInUseCase: dependencies.clockIn,
            clockOutUseCase: dependencies.clockOut,
            getWeeklyStatsUseCase: dependencies.getWeeklyStats,
            attendanceRepository: dependencies.attendanceRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(
            getHistory: dependencies.getAttendanceHistory,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            updateProfile: dependencies.updateProfile,
            changePassword: dependencies.changePassword,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            repository: dependencies.notificationRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(
            repository: dependencies.adminRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LeaveProvider(
            submitLeaveUseCase: dependencies.submitLeave,
            getMyLeavesUseCase: dependencies.getMyLeaves,
            getPendingLeavesUseCase: dependencies.getPendingLeaves,
            reviewLeaveUseCase: dependencies.reviewLeave,
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        onGenerateRoute: AppRouter.generateRoute,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final status = auth.status;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (status) {
        AuthStatus.bootstrapping => const SplashScreen(key: ValueKey('splash')),
        AuthStatus.authenticated => auth.user?.role.value == 'admin'
            ? const AdminDashboardScreen(key: ValueKey('admin_main'))
            : const MainScreen(key: ValueKey('main')),
        AuthStatus.unauthenticated ||
        AuthStatus.authenticating => const LoginScreen(key: ValueKey('login')),
      },
    );
  }
}
