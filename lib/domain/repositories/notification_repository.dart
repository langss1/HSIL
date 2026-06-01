import '../../core/utils/app_result.dart';
import '../entities/notification_entity.dart';

/// Contract for notification operations.
abstract interface class NotificationRepository {
  /// Fetches all notifications for a user.
  Future<AppResult<List<NotificationEntity>>> getNotifications(String userId);

  /// Saves a new notification.
  Future<AppResult<void>> saveNotification({
    required String userId,
    required NotificationEntity notification,
  });

  /// Marks a single notification as read.
  Future<AppResult<void>> markAsRead({
    required String userId,
    required String notificationId,
  });

  /// Marks all notifications as read.
  Future<AppResult<void>> markAllAsRead(String userId);

  /// Returns a stream of unread notification count.
  Stream<int> watchUnreadCount(String userId);
}
