import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../constants/app_constants.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({
    required this.isReady,
    this.message,
    this.stackTrace,
  });

  final bool isReady;
  final String? message;
  final StackTrace? stackTrace;
}

/// Initializes Firebase services while keeping development builds resilient
/// when project credentials have not been supplied yet.
class FirebaseBootstrapService {
  const FirebaseBootstrapService();

  Future<FirebaseBootstrapResult> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await _configureFirestore();
      await _configureAnalytics();
      await _configureCrashlytics();
      await _configureMessaging();

      final configMessage =
          AppConstants.hasFirebaseDartDefines
              ? 'Firebase project config loaded from dart-define.'
              : 'Using placeholder Firebase config. Supply dart-define values before production.';

      return FirebaseBootstrapResult(isReady: true, message: configMessage);
    } catch (error, stackTrace) {
      debugPrint('Firebase bootstrap failed: $error');
      return FirebaseBootstrapResult(
        isReady: false,
        message:
            'Firebase belum siap. App berjalan dalam mode UI/offline sampai config valid diberikan.',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _configureFirestore() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<void> _configureAnalytics() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }

  Future<void> _configureCrashlytics() async {
    if (kIsWeb) {
      return;
    }

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
        ),
      );
      return true;
    };
  }

  Future<void> _configureMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setAutoInitEnabled(true);
    } catch (error) {
      debugPrint('FCM setup deferred: $error');
    }
  }
}
