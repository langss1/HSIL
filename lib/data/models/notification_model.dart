import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

/// Firestore-backed model for [NotificationEntity].
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.timestamp,
    super.isRead,
    super.data,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'info',
      timestamp: _dateFromJson(data['timestamp']) ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      data: (data['data'] as Map<String, dynamic>?) ?? const {},
    );
  }

  factory NotificationModel.fromRemoteMessage({
    required String id,
    required String title,
    required String body,
    String type = 'info',
    Map<String, dynamic> data = const {},
  }) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'data': data,
    };
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
