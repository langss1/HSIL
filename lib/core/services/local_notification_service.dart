import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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

  static Future<void> scheduleDailyReminder({bool hasClockedInToday = false}) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Schedule for Monday(1) to Friday(5)
    for (int i = 1; i <= 5; i++) {
      tz.TZDateTime scheduledDate = _nextInstanceOfWorkdayAt(i, 7, 30);

      // Smart Cancellation: If today is the scheduled day and user already clocked in, push to next week
      if (hasClockedInToday && scheduledDate.year == now.year && scheduledDate.month == now.month && scheduledDate.day == now.day) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      await _notificationsPlugin.zonedSchedule(
        100 + i, // IDs: 101 to 105
        'Peringatan Absensi',
        'Selamat Pagi! Jangan lupa melakukan Clock In hari ini.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Daily Reminders',
            channelDescription: 'Pengingat absen harian',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static tz.TZDateTime _nextInstanceOfWorkdayAt(int weekday, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }
}
