import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../data/datasources/firestore_notification_data_source.dart';
import '../../data/models/notification_model.dart';

/// Enhanced FCM service that saves incoming notifications to Firestore.
class NotificationService {
  NotificationService(
    this._messaging, {
    this.notificationDataSource,
  });

  final FirebaseMessaging? _messaging;
  final FirestoreNotificationDataSource? notificationDataSource;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  String? _currentUserId;

  /// Sets the current user ID for saving notifications.
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

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
        (message) {
          _saveNotification(message);
          (onForegroundMessage ?? _logMessage)(message);
        },
      );
      _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {
          _saveNotification(message);
          (onMessageOpenedApp ?? _logMessage)(message);
        },
      );
      return token;
    } catch (error) {
      debugPrint('Unable to initialize notification service: $error');
      return null;
    }
  }

  /// Saves an incoming FCM message to Firestore.
  Future<void> _saveNotification(RemoteMessage message) async {
    if (_currentUserId == null || notificationDataSource == null) return;
    try {
      final notification = message.notification;
      final model = NotificationModel.fromRemoteMessage(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification?.title ?? 'Notifikasi',
        body: notification?.body ?? '',
        type: message.data['type'] as String? ?? 'info',
        data: message.data,
      );
      await notificationDataSource!.saveNotification(_currentUserId!, model);
    } catch (e) {
      debugPrint('Failed to save notification: $e');
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
