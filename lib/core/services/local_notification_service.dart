import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap here if needed
      },
    );

    // Request permissions for Android 13+
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? userId,
    String? type,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'attendance_channel', // channel Id
      'Attendance Notifications', // channel Name
      channelDescription: 'Notifications for clock-in and clock-out status',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );

    // Auto-save to Firestore history if userId is provided
    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': userId,
          'title': title,
          'body': body,
          'type': type ?? 'info',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'data': {},
        });
      } catch (_) {}
    }
  }
}
