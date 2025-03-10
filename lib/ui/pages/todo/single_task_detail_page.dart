import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/domain/bloc/todo_bloc/todo_bloc.dart';

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
            backgroundColor: theme.colorScheme.background,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.star_border,
                      color: theme.colorScheme.onBackground),
                  onPressed: () {},
                )
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          task.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: theme.dividerTheme.color, height: 1),
                _buildActionRow(
                  context: context,
                  icon: Icons.add,
                  label: 'Add Step',
                  color: theme.colorScheme.primary,
                  onTap: () {},
                ),
                Divider(color: theme.dividerTheme.color, height: 1),
                _buildActionRow(
                  context: context,
                  icon: Icons.wb_sunny_outlined,
                  label: 'Add to My Day',
                  onTap: () {},
                ),
                Divider(color: theme.dividerTheme.color, height: 1),
                _buildActionRow(
                  context: context,
                  icon: Icons.notifications_none,
                  label: 'Remind Me',
                  onTap: () {},
                ),
                Divider(color: theme.dividerTheme.color, height: 1),
                _buildActionRow(
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Add Due Date',
                  onTap: () {},
                ),
                Divider(color: theme.dividerTheme.color, height: 1),
                _buildActionRow(
                  context: context,
                  icon: Icons.repeat,
                  label: 'Repeat',
                  onTap: () {},
                ),
                Divider(color: theme.dividerTheme.color, height: 1),
                _buildActionRow(
                  context: context,
                  icon: Icons.person_outline,
                  label: 'Assign to',
                  onTap: () {},
                ),
                Divider(color: theme.dividerTheme.color, height: 1),
                _buildActionRow(
                  context: context,
                  icon: Icons.attach_file,
                  label: 'Add File',
                  onTap: () {},
                ),
                Divider(color: theme.dividerTheme.color, height: 1),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Add Note',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        'Created ${_formatDate(task.reminderTime ?? todo.createdTime)} by ${task.assignedTo ?? 'Tapiwa Tererai'}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.6),
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          body: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        );
      },
    );
  }

  Widget _buildActionRow({
    required BuildContext context,
    required IconData icon,
    required String label,
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
              color: color ?? theme.colorScheme.onBackground.withOpacity(0.8),
              size: 22,
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.9),
              ),
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
    return 'Mon, 25 Nov 2024'; // Matching the date in the image
  }
}
