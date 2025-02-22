import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/model/todo_model.dart';
import 'add_task_dialogue.dart';

@RoutePage()
class TodoListPage extends StatelessWidget {
  final Todo todo;

  const TodoListPage({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(todo.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            todo.name,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: todo.isCompleted,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<TodoBloc>().add(UpdateTodo(
                                    todo: todo.copyWith(isCompleted: value),
                                  ));
                            }
                          },
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(DateFormat.yMMMd().format(todo.createdTime)),
                          const SizedBox(width: 16),
                          Icon(Icons.people,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text('${todo.collaborators.length} collaborators'),
                        ],
                      ),
                    ),
                  ),

                  // Tasks Section
                  if (todo.tasks.isNotEmpty) const Divider(),

                  // Task List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todo.tasks.length,
                    itemBuilder: (context, index) {
                      final task = todo.tasks[index];
                      return TaskListTile(
                        task: task,
                        onToggleComplete: (completed) {
                          context.read<TodoBloc>().add(
                                UpdateTask(
                                  todoId: todo.id,
                                  task: task.copyWith(isCompleted: completed),
                                ),
                              );
                        },
                      );
                    },
                  ),

                  // Action Buttons
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.add_task),
                        label: const Text('Add Task'),
                        onPressed: () => _showAddTaskDialog(context),
                      ),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit Todo'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Delete Todo'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showEditTodoDialog(context);
                              break;
                            case 'delete':
                              _showDeleteConfirmation(context);
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final task = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(todoId: todo.id),
    );

    if (task != null && context.mounted) {
      context.read<TodoBloc>().add(AddTask(
            todoId: todo.id,
            taskName: task.name,
            assignedTo: task.assignedTo,
            reminderTime: task.reminderTime,
            isImportant: task.isImportant,
          ));
    }
  }

  Future<void> _showEditTodoDialog(BuildContext context) async {
    // Implementation for editing todo
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<TodoBloc>().add(DeleteTodo(todoId: todo.id));
    }
  }
}

class TaskListTile extends StatelessWidget {
  final Task task;
  final Function(bool) onToggleComplete;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (value) {
          if (value != null) {
            onToggleComplete(value);
          }
        },
      ),
      title: Text(
        task.name,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.assignedTo != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text(task.assignedTo!),
              ],
            ),
          ],
          if (task.reminderTime != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.alarm, size: 16),
                const SizedBox(width: 4),
                Text(DateFormat.yMMMd().add_jm().format(task.reminderTime!)),
              ],
            ),
          ],
        ],
      ),
      trailing:
          task.isImportant ? const Icon(Icons.star, color: Colors.amber) : null,
    );
  }
}
