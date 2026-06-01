import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

/// Remote data source for the user's notification sub-collection.
class FirestoreNotificationDataSource {
  FirestoreNotificationDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Reference to a user's notifications sub-collection.
  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  /// Fetches all notifications, ordered by timestamp descending.
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final snapshot = await _collection(userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      return snapshot.docs
          .map(NotificationModel.fromFirestore)
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal memuat notifikasi.',
        code: error.code,
      );
    }
  }

  /// Saves a notification document.
  Future<void> saveNotification(
    String userId,
    NotificationModel model,
  ) async {
    try {
      await _collection(userId).doc(model.id).set(model.toJson());
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal menyimpan notifikasi.',
        code: error.code,
      );
    }
  }

  /// Marks a notification as read.
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _collection(userId).doc(notificationId).update({'isRead': true});
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal memperbarui notifikasi.',
        code: error.code,
      );
    }
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final docs = await _collection(userId)
          .where('isRead', isEqualTo: false)
          .get();
      for (final doc in docs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        error.message ?? 'Gagal memperbarui notifikasi.',
        code: error.code,
      );
    }
  }

  /// Streams the count of unread notifications.
  Stream<int> watchUnreadCount(String userId) {
    return _collection(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
