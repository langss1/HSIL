import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Thin FCM boundary. Foreground display can later be paired with local
/// notifications without changing feature screens.
class NotificationService {
  NotificationService(this._messaging);

  final FirebaseMessaging? _messaging;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  Future<String?> initialize({
    void Function(RemoteMessage message)? onForegroundMessage,
    void Function(RemoteMessage message)? onMessageOpenedApp,
  }) async {
    if (_messaging == null) {
      return null;
    }

    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await _messaging.getToken();
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        onForegroundMessage ?? _logMessage,
      );
      _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        onMessageOpenedApp ?? _logMessage,
      );
      return token;
    } catch (error) {
      debugPrint('Unable to initialize notification service: $error');
      return null;
    }
  }

  void dispose() {
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedAppSubscription?.cancel());
  }

  void _logMessage(RemoteMessage message) {
    debugPrint(
      'FCM message: ${message.messageId} ${message.notification?.title}',
    );
  }
}
