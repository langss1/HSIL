import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

/// Remote data source for the user's notification collection.
class FirestoreNotificationDataSource {
  FirestoreNotificationDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Reference to a user's notifications collection.
  Query<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('notifications').where('userId', isEqualTo: userId);

  /// Fetches all notifications, sorted locally.
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      // Fetch without orderBy to avoid Composite Index errors
      final snapshot = await _collection(userId).get();
      
      final docs = snapshot.docs
          .map(NotificationModel.fromFirestore)
          .toList(growable: false);
          
      // Sort locally descending by time
      docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      if (docs.length > 50) {
        return docs.sublist(0, 50);
      }
      return docs;
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
      await _firestore.collection('notifications').doc(model.id).set({
        ...model.toJson(),
        'userId': userId,
      });
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
      await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
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
