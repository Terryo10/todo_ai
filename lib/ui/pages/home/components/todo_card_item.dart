import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/bloc/theme_bloc/theme_bloc.dart';
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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final completionPercentage = _calculateCompletionPercentage();
        final percentageDisplay = '${(completionPercentage * 100).round()}%';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        percentageDisplay,
                        style: TextStyle(
                          color: colorScheme.primary,
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
                        style: TextStyle(
                          color: colorScheme.onSurface,
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
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
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
                              backgroundColor:
                                  theme.progressIndicatorTheme.linearTrackColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
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
                      SingleTodoRoute(
                        todo: todo,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
