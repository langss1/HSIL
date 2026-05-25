import 'package:flutter/foundation.dart';

/// Central app-level constants used across layers.
class AppConstants {
  const AppConstants._();

  static const String appName = 'HSIL Attendance';
  static const String appTagline = 'Factory attendance, safer and smarter.';
  static const String nikEmailDomain = 'factory.internal';

  static const String officeName = 'HSIL Main Plant';
  static const double officeLatitude = -6.2088;
  static const double officeLongitude = 106.8456;
  static const double officeRadiusMeters = 500;
  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const Duration authRetryDelay = Duration(milliseconds: 450);
  static const int maxRetryAttempts = 3;

  /// Runtime Firebase config can be passed through --dart-define.
  static const bool hasFirebaseDartDefines =
      String.fromEnvironment('FIREBASE_PROJECT_ID').length > 0 &&
      String.fromEnvironment('FIREBASE_API_KEY').length > 0;

  /// Keep demo auth opt-in so production builds do not accept local users.
  static const bool allowDemoAuth = bool.fromEnvironment(
    'ALLOW_DEMO_AUTH',
    defaultValue: false,
  );

  static bool get isDebug => kDebugMode;
}
