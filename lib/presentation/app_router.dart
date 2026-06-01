import 'package:flutter/material.dart';

import '../core/constants/route_constants.dart';
import '../domain/entities/attendance_record.dart';
import 'screens/attendance_detail_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/main_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/gps_validation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      RouteConstants.splash => const SplashScreen(),
      RouteConstants.login => const LoginScreen(),
      RouteConstants.register => const RegisterScreen(),
      RouteConstants.forgotPassword => const ForgotPasswordScreen(),
      RouteConstants.dashboard => const MainScreen(),
      RouteConstants.gpsValidation => const GPSValidationScreen(),
      RouteConstants.attendanceDetail => AttendanceDetailScreen(
          record: settings.arguments! as AttendanceRecord,
        ),
      RouteConstants.editProfile => const EditProfileScreen(),
      RouteConstants.changePassword => const ChangePasswordScreen(),
      RouteConstants.notifications => const NotificationScreen(),
      _ => const LoginScreen(),
    };
    return _buildRoute(page, settings);
  }

  static PageRouteBuilder<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (_, animation, __, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.06, 0),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }
}
