part of 'notifications_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class NotificationsUpdated extends NotificationEvent {
  final List<NotificationModel> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class UnreadCountUpdated extends NotificationEvent {
  final int count;

  const UnreadCountUpdated(this.count);

  @override
  List<Object> get props => [count];
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class ClearAllNotifications extends NotificationEvent {}