import 'package:flutter/material.dart';

import '../core/constants/route_constants.dart';
import '../domain/entities/attendance_record.dart';
import '../domain/entities/app_user.dart';
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
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/employee_list_screen.dart';
import 'screens/admin/admin_map_screen.dart';
import 'screens/admin/kpi_dashboard_screen.dart';
import 'screens/admin/employee_detail_screen.dart';
import 'screens/admin/admin_attendance_log_screen.dart';
import 'screens/admin/admin_add_employee_screen.dart';
import 'screens/admin/admin_broadcast_screen.dart';
import 'screens/leave_request_screen.dart';
import 'screens/admin/leave_approval_screen.dart';
import 'screens/admin/leave_history_screen.dart';

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
      RouteConstants.leaveRequest => const LeaveRequestScreen(),

      // Admin
      RouteConstants.adminAddEmployee => const AdminAddEmployeeScreen(),
      RouteConstants.adminBroadcast => const AdminBroadcastScreen(),
      RouteConstants.adminDashboard => const AdminDashboardScreen(),
      RouteConstants.employeeList => const EmployeeListScreen(),
      RouteConstants.adminMap => const AdminMapScreen(),
      RouteConstants.kpiDashboard => const KpiDashboardScreen(),
      RouteConstants.employeeDetail => EmployeeDetailScreen(
          employee: settings.arguments! as AppUser,
        ),
      RouteConstants.adminAttendanceLog => AdminAttendanceLogScreen(
          initialEmployee: settings.arguments as AppUser?,
        ),
      RouteConstants.leaveApproval => const LeaveApprovalScreen(),
      RouteConstants.leaveHistory => const LeaveHistoryScreen(),
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
