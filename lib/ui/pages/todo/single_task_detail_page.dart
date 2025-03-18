import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/domain/bloc/todo_bloc/todo_bloc.dart';
import 'package:todo_ai/domain/model/todo_model.dart';

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
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 24,
                  ),
                  onPressed: () {
                    final updatedTask =
                        task.copyWith(isImportant: !task.isImportant);
                    context
                        .read<TodoBloc>()
                        .add(UpdateTask(todoId: todoId, task: updatedTask));
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
                        theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 24,
                    thickness: 1,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildStepsList(context, theme, task),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildActionRow(
                      context: context,
                      icon: Icons.add,
                      label: 'Add Step',
                      color: theme.colorScheme.primary,
                      onTap: () {
                        _showAddStepDialog(context, todoId, taskId);
                      },
                    ),
                    // Divider(
                    //     color: theme.dividerTheme.color ??
                    //         theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    //     height: 1),
                    // _buildActionRow(
                    //   context: context,
                    //   icon: Icons.wb_sunny_outlined,
                    //   label: 'Add to My Day',
                    //   onTap: () {
                    //     // Add to my day logic
                    //   },
                    // ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withValues(alpha: 0.1),
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
                        _showReminderPicker(context, todoId, task);
                      },
                    ),
                    // Divider(
                    //     color: theme.dividerTheme.color ??
                    //         theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    //     height: 1),
                    // _buildActionRow(
                    //   context: context,
                    //   icon: Icons.calendar_today_outlined,
                    //   label: 'Add Due Date',
                    //   onTap: () {
                    //     // Due date logic
                    //   },
                    // ),
                    // Divider(
                    //     color: theme.dividerTheme.color ??
                    //         theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    //     height: 1),
                    // _buildActionRow(
                    //   context: context,
                    //   icon: Icons.repeat,
                    //   label: 'Repeat',
                    //   onTap: () {
                    //     // Repeat logic
                    //   },
                    // ),
                    Divider(
                        color: theme.dividerTheme.color ??
                            theme.colorScheme.onSurface.withValues(alpha: 0.1),
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
                    // Divider(
                    //     color: theme.dividerTheme.color ??
                    //         theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    //     height: 1),
                    // _buildActionRow(
                    //   context: context,
                    //   icon: Icons.attach_file,
                    //   label: 'Add File',
                    //   onTap: () {
                    //     // Add file logic
                    //   },
                    // ),
                    // Divider(
                    //     color: theme.dividerTheme.color ??
                    //         theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    //     height: 1),
                    // _buildNoteSection(context, theme),
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
              context.read<TodoBloc>().add(CompleteTask(
                  todoId: todoId,
                  taskId: taskId,
                  isCompleted: !task.isCompleted));
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
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
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
              color:
                  color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color ??
                      theme.colorScheme.onSurface.withValues(alpha: 0.9),
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
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
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

  void _showDeleteConfirmation(
      BuildContext context, String todoId, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<TodoBloc>()
                  .add(DeleteTask(todoId: todoId, taskId: taskId));
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Widget _buildNoteSection(BuildContext context, ThemeData theme) {
  //   return Padding(
  //     padding: const EdgeInsets.all(20.0),
  //     child: InkWell(
  //       onTap: () {
  //         // Open note editor
  //       },
  //       borderRadius: BorderRadius.circular(8),
  //       child: Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: theme.colorScheme.surface,
  //           borderRadius: BorderRadius.circular(8),
  //           border: Border.all(
  //             color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
  //           ),
  //         ),
  //         child: Text(
  //           'Add Note',
  //           style: theme.textTheme.bodyMedium?.copyWith(
  //             color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error.withValues(alpha: 0.8),
                size: 22,
              ),
              onPressed: () {
                _showDeleteConfirmation(context, todoId, taskId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStepDialog(BuildContext context, String todoId, String taskId) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Step'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Enter step description'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                // Add step logic here using a new "AddTaskStep" event
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showReminderPicker(BuildContext context, String todoId, Task task) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          if (selectedTime != null) {
            final reminderDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            final updatedTask = task.copyWith(reminderTime: reminderDateTime);
            context
                .read<TodoBloc>()
                .add(UpdateTask(todoId: todoId, task: updatedTask));
          }
        });
      }
    });
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

  Widget _buildStepsList(BuildContext context, ThemeData theme, Task task) {
    return Column(
      children: [
        if (task.steps.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'Steps',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha:0.8),
                    ),
                  ),
                ),
                ...task.steps.map(
                    (step) => _buildStepItem(context, theme, task.id, step)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStepItem(
      BuildContext context, ThemeData theme, String taskId, TaskStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              context.read<TodoBloc>().add(
                    CompleteTaskStep(
                      todoId: todoId,
                      taskId: taskId,
                      stepId: step.id,
                      isCompleted: !step.isCompleted,
                    ),
                  );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? theme.colorScheme.primary.withValues(alpha:0.2)
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha:0.3),
                  width: 1.5,
                ),
              ),
              child: step.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: step.isCompleted
                    ? theme.colorScheme.onSurface.withValues(alpha:0.6)
                    : theme.colorScheme.onSurface,
                decoration: step.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha:0.5),
            ),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Step'),
                  content:
                      const Text('Are you sure you want to delete this step?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add a DeleteTaskStep event
                        context.read<TodoBloc>().add(
                              DeleteTaskStep(
                                todoId: todoId,
                                taskId: taskId,
                                stepId: step.id,
                              ),
                            );
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
