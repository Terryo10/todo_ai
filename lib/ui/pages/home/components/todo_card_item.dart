import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../domain/model/todo_model.dart';
import '../../../../routes/router.gr.dart';

class TodoCardItem extends StatelessWidget {
  final Todo todo;

  const TodoCardItem({
    super.key,
    required this.todo,
  });

  double _calculateCompletionPercentage() {
    if (todo.tasks.isEmpty) return 0.0;

    int completedTasks = todo.tasks.where((task) => task.isCompleted).length;
    return completedTasks / todo.tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final completionPercentage = _calculateCompletionPercentage();
    final percentageDisplay = '${(completionPercentage * 100).round()}%';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7553F6).withValues(alpha: 0.2),
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FittedBox(
                  child: Text(
                    percentageDisplay,
                    style: const TextStyle(
                      color: Color(0xFF7553F6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    todo.name.toLowerCase(),
                    style: const TextStyle(
                      color: Color(0xFF2A2A2A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        '${todo.tasks.length} Tasks',
                        style: TextStyle(
                          color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        child: LinearProgressIndicator(
                          value: completionPercentage,
                          backgroundColor: const Color(0xFFEEEEFF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF7553F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.navigateTo(
                  TodoListRoute(
                    todo: todo,
                  ),
                );
              },
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF7553F6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
