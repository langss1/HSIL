import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required NotificationRepository repository})
      : _repository = repository;

  final NotificationRepository _repository;

  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<int>? _unreadSubscription;

  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUnread => _unreadCount > 0;

  /// Grouped notifications for UI display.
  Map<String, List<NotificationEntity>> get groupedNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<NotificationEntity>>{
      'Hari Ini': [],
      'Kemarin': [],
      'Lebih Lama': [],
    };

    for (final n in _notifications) {
      final nDate = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
      if (nDate == today) {
        groups['Hari Ini']!.add(n);
      } else if (nDate == yesterday) {
        groups['Kemarin']!.add(n);
      } else {
        groups['Lebih Lama']!.add(n);
      }
    }

    // Remove empty groups
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  /// Initialize unread count stream.
  void startWatching(String userId) {
    _unreadSubscription?.cancel();
    _unreadSubscription = _repository.watchUnreadCount(userId).listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  /// Load all notifications.
  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getNotifications(userId);
    result.when(
      success: (list) {
        _notifications = list;
        _isLoading = false;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
      },
    );
    notifyListeners();
  }

  /// Mark one as read.
  Future<void> markAsRead(String userId, String notificationId) async {
    await _repository.markAsRead(userId: userId, notificationId: notificationId);
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      final old = _notifications[idx];
      _notifications[idx] = NotificationEntity(
        id: old.id,
        title: old.title,
        body: old.body,
        type: old.type,
        timestamp: old.timestamp,
        isRead: true,
        data: old.data,
      );
      notifyListeners();
    }
  }

  /// Mark all as read.
  Future<void> markAllAsRead(String userId) async {
    await _repository.markAllAsRead(userId);
    _notifications = _notifications.map((n) => NotificationEntity(
      id: n.id,
      title: n.title,
      body: n.body,
      type: n.type,
      timestamp: n.timestamp,
      isRead: true,
      data: n.data,
    )).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _unreadSubscription?.cancel();
    super.dispose();
  }
}
