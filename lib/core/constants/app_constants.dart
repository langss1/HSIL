import 'package:flutter/foundation.dart';

/// Central app-level constants used across layers.
class AppConstants {
  const AppConstants._();

  static const String appName    = 'Absen!';
  static const String appTagline = 'Factory attendance, safer and smarter.';

  // Firebase project
  static const String firebaseProjectId  = 'hsil-attendance';
  static const String firebaseProjectNo  = '863084950012';
  static const String nikEmailDomain     = 'hsil.factory'; // NIK@hsil.factory

  // Office / GPS
  static const String officeName          = 'Telkom University Bandung';
  static const double officeLatitude      = -6.97328;
  static const double officeLongitude     = 107.63034;
  static const double officeRadiusMeters  = 1500;

  // Timing
  static const Duration splashDuration   = Duration(milliseconds: 1500);
  static const Duration authRetryDelay   = Duration(milliseconds: 450);
  static const int      maxRetryAttempts = 3;

  // Attendance timing
  static const String defaultShiftStart = '08:00';
  static const int lateThresholdMinutes = 15; // telat jika > 15 menit dari shift start
  static const int gpsDistanceFilter    = 10; // meters — geofence stream update interval

  /// Firebase is now configured with real credentials — always true.
  static const bool hasFirebaseDartDefines = true;

  /// Keep demo auth opt-in so production builds do not accept local users.
  static const bool allowDemoAuth = bool.fromEnvironment(
    'ALLOW_DEMO_AUTH',
    defaultValue: false,
  );

  static bool get isDebug => kDebugMode;
}
