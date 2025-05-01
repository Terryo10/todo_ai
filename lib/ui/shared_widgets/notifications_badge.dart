// lib/ui/shared_widgets/notification_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/bloc/notifications_bloc/notifications_bloc.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final double badgeSize;
  final Color? badgeColor;

  const NotificationBadge({
    super.key,
    required this.child,
    this.badgeSize = 8.0,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final hasNotifications = state is NotificationsLoaded && state.unreadCount > 0;
        
        if (!hasNotifications) {
          return child;
        }
        
        return Stack(
          alignment: Alignment.center,
          children: [
            child,
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: badgeColor ?? Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// For larger badges with text
class CountBadge extends StatelessWidget {
  final Widget child;
  final double badgeSize;
  final Color? badgeColor;
  final Color? textColor;

  const CountBadge({
    Key? key,
    required this.child,
    this.badgeSize = 16.0,
    this.badgeColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unreadCount = state is NotificationsLoaded ? state.unreadCount : 0;
        
        if (unreadCount <= 0) {
          return child;
        }
        
        final displayCount = unreadCount > 99 ? '99+' : unreadCount.toString();
        
        return Stack(
          alignment: Alignment.center,
          children: [
            child,
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(badgeSize > 16 ? 4 : 2),
                constraints: BoxConstraints(
                  minWidth: badgeSize,
                  minHeight: badgeSize,
                ),
                decoration: BoxDecoration(
                  color: badgeColor ?? Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    displayCount,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: badgeSize > 16 ? 10 : 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}