/// Represents an in-app notification.
class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data = const {},
  });

  final String id;
  final String title;
  final String body;
  /// Type: 'reminder', 'success', 'failure', 'info'
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> data;
}
