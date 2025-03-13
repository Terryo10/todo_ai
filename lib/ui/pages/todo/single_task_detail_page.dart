import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/domain/bloc/todo_bloc/todo_bloc.dart';

import 'widgets/assignee_chip.dart';
import 'widgets/task_asignment.dart';

@RoutePage()
class SingleTaskDetailPage extends StatelessWidget {
  final String todoId;
  final String taskId;

  const SingleTaskDetailPage(
      {super.key, required this.todoId, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state is TodoLoaded) {
          final todo = state.todos.firstWhere((t) => t.id == todoId);
          final task = todo.tasks.firstWhere((t) => t.id == taskId);

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              leadingWidth: 40,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    task.isImportant ? Icons.star : Icons.star_border,
                    color: task.isImportant
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    size: 24,
                  ),
                  onPressed: () {
                    // Toggle isImportant state
                    // context.read<TodoBloc>().add(
                    //   UpdateTaskImportance(todoId: todoId, taskId: taskId, isImportant: !task.isImportant)
                    // );
                  },
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTaskHeader(context, theme, task),
                ),
                SliverToBoxAdapter(
                  child: Divider(
                    color: theme.dividerTheme.color ??
                        theme.colorScheme.onSurface.withOpacity(0.1),
                    height: 24,
                    thickness: 1,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildActionRow(
                      context: context,
                      icon: Icons.add,
                      label: 'Add Step',
                      color: theme.colorScheme.primary,
                      onTap: () {
                        // Add step logic
                      },
                    ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withOpacity(0.1),
                        height: 1),
                    _buildActionRow(
                      context: context,
                      icon: Icons.wb_sunny_outlined,
                      label: 'Add to My Day',
                      onTap: () {
                        // Add to my day logic
                      },
                    ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withOpacity(0.1),
                        height: 1),
                    _buildActionRow(
                      context: context,
                      icon: Icons.notifications_none,
                      label: 'Remind Me',
                      trailing: task.reminderTime != null
                          ? _buildReminderChip(
                              context, task.reminderTime!, theme)
                          : null,
                      onTap: () {
                        // Reminder logic
                      },
                    ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withOpacity(0.1),
                        height: 1),
                    _buildActionRow(
                      context: context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Add Due Date',
                      onTap: () {
                        // Due date logic
                      },
                    ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withOpacity(0.1),
                        height: 1),
                    _buildActionRow(
                      context: context,
                      icon: Icons.repeat,
                      label: 'Repeat',
                      onTap: () {
                        // Repeat logic
                      },
                    ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withOpacity(0.1),
                        height: 1),
                    _buildActionRow(
                      context: context,
                      icon: Icons.person_outline,
                      label: 'Assign to',
                      trailing: AssigneeChip(
                        assigneeId: task.assignedTo,
                        showUnassigned: true,
                        onTap: () {
                          showTaskAssignmentDialog(
                            context,
                            todoId: todoId,
                            taskId: taskId,
                            taskName: task.name,
                            collaborators: todo.collaborators,
                            currentAssignee: task.assignedTo,
                          );
                        },
                      ),
                      onTap: () {
                        showTaskAssignmentDialog(
                          context,
                          todoId: todoId,
                          taskId: taskId,
                          taskName: task.name,
                          collaborators: todo.collaborators,
                          currentAssignee: task.assignedTo,
                        );
                      },
                    ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withOpacity(0.1),
                        height: 1),
                    _buildActionRow(
                      context: context,
                      icon: Icons.attach_file,
                      label: 'Add File',
                      onTap: () {
                        // Add file logic
                      },
                    ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withOpacity(0.1),
                        height: 1),
                    _buildNoteSection(context, theme),
                  ]),
                ),
                // Add spacing at the bottom
                SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
            bottomSheet: _buildBottomInfo(context, theme, task, todo),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        );
      },
    );
  }

  Widget _buildTaskHeader(BuildContext context, ThemeData theme, dynamic task) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              // Toggle completion status
              // context.read<TodoBloc>().add(
              //   UpdateTaskCompletion(todoId: todoId, taskId: taskId, isCompleted: !task.isCompleted)
              // );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              task.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: task.isCompleted
                    ? theme.colorScheme.onSurface.withOpacity(0.6)
                    : theme.colorScheme.onSurface,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    Widget? trailing,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? theme.colorScheme.onSurface.withOpacity(0.7),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color ?? theme.colorScheme.onSurface.withOpacity(0.9),
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildReminderChip(
      BuildContext context, DateTime reminderTime, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _formatReminderTime(reminderTime),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          // Open note editor
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
          child: Text(
            'Add Note',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(
      BuildContext context, ThemeData theme, dynamic task, dynamic todo) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Created ${_formatDate(task.reminderTime ?? todo.createdTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error.withOpacity(0.8),
                size: 22,
              ),
              onPressed: () {
                // Delete task logic
                // showDialog(...)
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${_getDayOfWeek(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _formatReminderTime(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      // Format like "Today, 3:00 PM"
      return 'Today, ${_formatTimeOfDay(date)}';
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      // Format like "Tomorrow, 3:00 PM"
      return 'Tomorrow, ${_formatTimeOfDay(date)}';
    }

    // Format like "Mon, 25 Nov, 3:00 PM"
    return '${_getDayOfWeek(date.weekday)}, ${date.day} ${_getMonth(date.month)}, ${_formatTimeOfDay(date)}';
  }

  String _formatTimeOfDay(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
