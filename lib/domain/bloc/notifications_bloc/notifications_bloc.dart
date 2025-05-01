// lib/domain/bloc/notification_bloc/notification_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/notifications_model.dart';

import '../../repositories/notification_repository/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _unreadCountSubscription;

  NotificationBloc({required NotificationRepository repository})
      : _repository = repository,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<UnreadCountUpdated>(_onUnreadCountUpdated);
  }

  void _onLoadNotifications(
      LoadNotifications event, Emitter<NotificationState> emit) {
    emit(NotificationsLoading());

    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();

    _notificationsSubscription = _repository.getNotifications().listen(
          (notifications) => add(NotificationsUpdated(notifications)),
        );

    _unreadCountSubscription = _repository.getUnreadCount().listen(
          (count) => add(UnreadCountUpdated(count)),
        );
  }

  void _onNotificationsUpdated(
      NotificationsUpdated event, Emitter<NotificationState> emit) {
    emit(NotificationsLoaded(
      notifications: event.notifications,
      unreadCount: event.notifications.where((n) => !n.isRead).length,
    ));
  }

  void _onUnreadCountUpdated(
      UnreadCountUpdated event, Emitter<NotificationState> emit) {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      emit(NotificationsLoaded(
        notifications: currentState.notifications,
        unreadCount: event.count,
      ));
    }
  }

  Future<void> _onMarkAsRead(
      MarkAsRead event, Emitter<NotificationState> emit) async {
    await _repository.markAsRead(event.notificationId);
  }

  Future<void> _onMarkAllAsRead(
      MarkAllAsRead event, Emitter<NotificationState> emit) async {
    await _repository.markAllAsRead();
  }

  Future<void> _onDeleteNotification(
      DeleteNotification event, Emitter<NotificationState> emit) async {
    await _repository.deleteNotification(event.notificationId);
  }

  Future<void> _onClearAllNotifications(
      ClearAllNotifications event, Emitter<NotificationState> emit) async {
    await _repository.clearAllNotifications();
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}