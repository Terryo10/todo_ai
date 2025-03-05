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
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state is TodoLoaded) {
          final todo = state.todos.firstWhere((t) => t.id == todoId);
          final task = todo.tasks.firstWhere((t) => t.id == taskId);

          return Scaffold(
            backgroundColor: const Color(0xFF1E1E1E),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1E1E1E),
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_back_ios,
                          color: Colors.blue, size: 18),
                      Text(
                        'SlimRiff',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              leadingWidth: 120,
              actions: [
                IconButton(
                  icon: const Icon(Icons.star_border, color: Colors.white),
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
                          color: Colors.grey.shade800,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          task.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF333333), height: 1),
                _buildActionRow(
                  icon: Icons.add,
                  label: 'Add Step',
                  color: Colors.blue,
                  onTap: () {},
                ),
                const Divider(color: Color(0xFF333333), height: 1),
                _buildActionRow(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Add to My Day',
                  onTap: () {},
                ),
                const Divider(color: Color(0xFF333333), height: 1),
                _buildActionRow(
                  icon: Icons.notifications_none,
                  label: 'Remind Me',
                  onTap: () {},
                ),
                const Divider(color: Color(0xFF333333), height: 1),
                _buildActionRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Add Due Date',
                  onTap: () {},
                ),
                const Divider(color: Color(0xFF333333), height: 1),
                _buildActionRow(
                  icon: Icons.repeat,
                  label: 'Repeat',
                  onTap: () {},
                ),
                const Divider(color: Color(0xFF333333), height: 1),
                _buildActionRow(
                  icon: Icons.person_outline,
                  label: 'Assign to',
                  onTap: () {},
                ),
                const Divider(color: Color(0xFF333333), height: 1),
                _buildActionRow(
                  icon: Icons.attach_file,
                  label: 'Add File',
                  onTap: () {},
                ),
                const Divider(color: Color(0xFF333333), height: 1),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Add Note',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
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
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.delete_outline,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const Scaffold(
          backgroundColor: Color(0xFF1E1E1E),
          body: Center(
            child: CircularProgressIndicator(color: Colors.blue),
          ),
        );
      },
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 16,
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
