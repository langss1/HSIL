import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/di/app_dependencies.dart';
import 'core/themes/app_theme.dart';
import 'presentation/app_router.dart';
import 'presentation/providers/attendance_provider.dart';
import 'presentation/providers/auth_controller.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    final status = context.select<AuthController, AuthStatus>(
      (auth) => auth.status,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (status) {
        AuthStatus.bootstrapping => const SplashScreen(key: ValueKey('splash')),
        AuthStatus.authenticated => const MainScreen(
          key: ValueKey('main'),
        ),
        AuthStatus.unauthenticated ||
        AuthStatus.authenticating => const LoginScreen(key: ValueKey('login')),
      },
    );
  }
}
