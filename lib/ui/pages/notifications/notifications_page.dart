// lib/ui/pages/notifications/notifications_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_ai/domain/services/invitation_service.dart';
import 'package:todo_ai/routes/router.gr.dart';

import '../../../domain/bloc/notifications_bloc/notifications_bloc.dart';
import '../../../domain/model/notifications_model.dart';

@RoutePage()
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    context.read<NotificationBloc>().add(MarkAllAsRead());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Clear all notifications',
                  onPressed: () {
                    _showClearConfirmationDialog(context);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _buildNotificationItem(context, notification);
              },
            );
          }

          return const Center(child: Text('Failed to load notifications'));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see invitations and updates here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, NotificationModel notification) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_Hm();

    // Different styling based on notification type
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.todoInvitation:
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case NotificationType.taskAssigned:
        iconData = Icons.assignment_ind;
        iconColor = Colors.blue;
        break;
      case NotificationType.taskCompleted:
        iconData = Icons.check_circle;
        iconColor = Colors.orange;
        break;
      case NotificationType.reminderDue:
        iconData = Icons.alarm;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = theme.colorScheme.primary;
    }

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context
            .read<NotificationBloc>()
            .add(DeleteNotification(notification.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () => _handleNotificationTap(context, notification),
        child: Container(
          color: notification.isRead
              ? null
              : theme.colorScheme.primaryContainer.withOpacity(0.1),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.2),
              child: Icon(iconData, color: iconColor),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(notification.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: notification.isRead
                ? null
                : Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(
      BuildContext context, NotificationModel notification) {
    // Mark as read first
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(MarkAsRead(notification.id));
    }

    // Handle based on notification type
    switch (notification.type) {
      case NotificationType.todoInvitation:
        _handleInvitationNotification(context, notification);
        break;
      case NotificationType.taskAssigned:
        _handleTaskAssignedNotification(context, notification);
        break;
      case NotificationType.taskCompleted:
        _handleTaskCompletedNotification(context, notification);
        break;
      case NotificationType.reminderDue:
        _handleReminderNotification(context, notification);
        break;
      default:
        // Just mark as read
        break;
    }
  }

  void _handleInvitationNotification(
      BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Todo Invitation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              'Would you like to accept this invitation?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Decline invitation
              try {
                final invitationService = context.read<InvitationService>();
                await invitationService.declineInvitation(
                  notification.data['invitationCode'],
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invitation declined'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Accept invitation
              try {
                final invitationService = context.read<InvitationService>();
                final todoId = await invitationService.acceptInvitation(
                  notification.data['invitationCode'],
                );

                if (context.mounted) {
                  // Close loading dialog
                  Navigator.of(context).pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invitation accepted'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to the todo
                  // context.navigateTo(SingleTodoRoute(todoId: todoId));
                }
              } catch (e) {
                if (context.mounted) {
                  // Close loading dialog
                  Navigator.of(context).pop();

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _handleTaskAssignedNotification(
      BuildContext context, NotificationModel notification) {
    if (notification.data.containsKey('todoId') &&
        notification.data.containsKey('taskId')) {
      // Navigate to task detail
      context.navigateTo(
        SingleTaskDetailRoute(
          todoId: notification.data['todoId'],
          taskId: notification.data['taskId'],
        ),
      );
    }
  }

  void _handleTaskCompletedNotification(
      BuildContext context, NotificationModel notification) {
    if (notification.data.containsKey('todoId')) {
      // Navigate to the todo
      // context.navigateTo(
      //   SingleTodoRoute(
      //     todoId: notification.data['todoId'], todo: null,
      //   ),
      // );
    }
  }

  void _handleReminderNotification(
      BuildContext context, NotificationModel notification) {
    if (notification.data.containsKey('todoId') &&
        notification.data.containsKey('taskId')) {
      // Navigate to task detail
      context.navigateTo(
        SingleTaskDetailRoute(
          todoId: notification.data['todoId'],
          taskId: notification.data['taskId'],
        ),
      );
    }
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
            'Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(ClearAllNotifications());
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
