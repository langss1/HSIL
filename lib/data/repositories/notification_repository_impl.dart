import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/firestore_notification_data_source.dart';
import '../models/notification_model.dart';

/// Concrete [NotificationRepository] backed by Firestore.
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required FirestoreNotificationDataSource dataSource,
  }) : _dataSource = dataSource;

  final FirestoreNotificationDataSource _dataSource;

  @override
  Future<AppResult<List<NotificationEntity>>> getNotifications(
    String userId,
  ) async {
    try {
      final list = await _dataSource.getNotifications(userId);
      return AppSuccess(list);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<void>> saveNotification({
    required String userId,
    required NotificationEntity notification,
  }) async {
    try {
      final model = NotificationModel(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        type: notification.type,
        timestamp: notification.timestamp,
        isRead: notification.isRead,
        data: notification.data,
      );
      await _dataSource.saveNotification(userId, model);
      return const AppSuccess(null);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<void>> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _dataSource.markAsRead(userId, notificationId);
      return const AppSuccess(null);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Future<AppResult<void>> markAllAsRead(String userId) async {
    try {
      await _dataSource.markAllAsRead(userId);
      return const AppSuccess(null);
    } catch (error) {
      return AppFailure(_mapFailure(error));
    }
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _dataSource.watchUnreadCount(userId);
  }

  Failure _mapFailure(Object error) {
    if (error is FirebaseDataException) {
      return DataFailure(error.message, code: error.code);
    }
    return UnknownFailure('Terjadi kesalahan notifikasi: $error');
  }
}
