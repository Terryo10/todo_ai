// lib/domain/repositories/notification_repository/notification_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/notifications_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get all notifications for the current user
  Stream<List<NotificationModel>> getNotifications() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _notifications
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data()))
            .toList());
  }

  // Get unread notifications count
  Stream<int> getUnreadCount() {
    if (_currentUserId == null) {
      return Stream.value(0);
    }

    return _notifications
        .where('userId', isEqualTo: _currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    final batch = _firestore.batch();
    final unreadNotifications = await _notifications
        .where('userId', isEqualTo: _currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _notifications.doc(notificationId).delete();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    if (_currentUserId == null) return;

    final batch = _firestore.batch();
    final notifications = await _notifications
        .where('userId', isEqualTo: _currentUserId)
        .get();

    for (final doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Create a new notification (typically used by services)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    required Map<String, dynamic> data,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );

    await _notifications.doc(notification.id).set(notification.toMap());
  }
}