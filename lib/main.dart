import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/di/app_dependencies.dart';
import 'core/themes/app_theme.dart';
import 'presentation/app_router.dart';
import 'presentation/providers/auth_controller.dart';
import 'presentation/screens/dashboard_screen.dart';
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
        AuthStatus.authenticated => const DashboardScreen(
          key: ValueKey('dashboard'),
        ),
        AuthStatus.unauthenticated ||
        AuthStatus.authenticating => const LoginScreen(key: ValueKey('login')),
      },
    );
  }
}
