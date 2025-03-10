import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/model/todo_model.dart';
import '../../../routes/router.gr.dart';
import 'add_task_dialogue.dart';

@RoutePage()
class SingleTodoPage extends StatefulWidget {
  final Todo todo;

  const SingleTodoPage({
    super.key,
    required this.todo,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SingleTodoPageState createState() => _SingleTodoPageState();
}

class _SingleTodoPageState extends State<SingleTodoPage> {
  bool _isPendingExpanded = true;
  bool _isCompletedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        Todo? currentTodo = state is TodoLoaded
            ? state.todos.firstWhere(
                (t) => t.id == widget.todo.id,
                orElse: () => widget.todo,
              )
            : widget.todo;

        // Separate completed and pending tasks
        final pendingTasks =
            currentTodo.tasks.where((task) => !task.isCompleted).toList();
        final completedTasks =
            currentTodo.tasks.where((task) => task.isCompleted).toList();

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.background,
            elevation: 0,
            leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: theme.colorScheme.onBackground),
                itemBuilder: (context) => [
                  _buildPopupMenuItem('Edit', Icons.edit),
                  _buildPopupMenuItem('Delete', Icons.delete),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'Edit':
                      _showEditTodoDialog(context, currentTodo);
                      break;
                    case 'Delete':
                      _showDeleteConfirmation(context, currentTodo);
                      break;
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTodoHeader(context, currentTodo),
                  const SizedBox(height: 20),

                  // Pending Tasks Section
                  if (pendingTasks.isNotEmpty) ...[
                    _buildExpandableSection(
                        context,
                        currentTodo,
                        pendingTasks,
                        'Pending',
                        _isPendingExpanded,
                        () => setState(
                            () => _isPendingExpanded = !_isPendingExpanded)),
                    const SizedBox(height: 16),
                  ],

                  // Completed Tasks Section
                  if (completedTasks.isNotEmpty) ...[
                    _buildExpandableSection(
                        context,
                        currentTodo,
                        completedTasks,
                        'Completed',
                        _isCompletedExpanded,
                        () => setState(() =>
                            _isCompletedExpanded = !_isCompletedExpanded)),
                  ],

                  // Add some bottom padding
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: theme.colorScheme.primary,
            onPressed: () => _showAddTaskDialog(context, currentTodo),
            child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
          ),
        );
      },
    );
  }

  Widget _buildExpandableSection(
      BuildContext context,
      Todo todo,
      List<Task> tasks,
      String sectionTitle,
      bool isExpanded,
      VoidCallback onToggle) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onBackground,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return _buildTaskItem(context, todo, tasks[index]);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, Todo todo, Task task) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFF5F5F5)
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          context.navigateTo(
            SingleTaskDetailRoute(
              todoId: todo.id,
              taskId: task.id,
            ),
          );
        },
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              width: 2,
            ),
            onChanged: (value) {
              if (value != null) {
                context.read<TodoBloc>().add(
                      UpdateTask(
                        todoId: todo.id,
                        task: task.copyWith(isCompleted: value),
                      ),
                    );
              }
            },
          ),
          title: Text(
            task.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.assignedTo != null)
                Text(
                  'Assigned to: ${task.assignedTo!}',
                  style: theme.textTheme.bodySmall,
                ),
              if (task.reminderTime != null)
                Text(
                  'Reminder: ${DateFormat.yMMMd().add_jm().format(task.reminderTime!)}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          trailing: task.isImportant
              ? const Icon(Icons.star, color: Colors.amber, size: 20)
              : null,
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String text, IconData icon) {
    final theme = Theme.of(context);

    return PopupMenuItem(
      value: text,
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurface),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoHeader(BuildContext context, Todo todo) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFF5F5F5)
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  todo.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Checkbox(
                value: todo.isCompleted,
                activeColor: theme.colorScheme.primary,
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
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today,
              'Created: ${DateFormat.yMMMd().format(todo.createdTime)}'),
          const SizedBox(height: 8),
          _buildInfoRow(
              Icons.people, '${todo.collaborators.length} Collaborators'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon,
            color: theme.colorScheme.onSurface.withOpacity(0.6), size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context, Todo todo) async {
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

  Future<void> _showEditTodoDialog(BuildContext context, Todo todo) async {
    // Will implement editing code here
    // final updatedTodo = await showDialog<Todo>(
    //   context: context,
    //   // builder: (context) => EditTodoDialog(todo: todo),
    // );

    // if (updatedTodo != null && context.mounted) {
    //   context.read<TodoBloc>().add(UpdateTodo(todo: updatedTodo));
    // }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Todo todo) async {
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Delete Todo', style: theme.textTheme.titleLarge),
        content: Text(
          'Are you sure you want to delete this todo?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: TextStyle(color: theme.colorScheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<TodoBloc>().add(DeleteTodo(todoId: todo.id));
      Navigator.of(context).pop(); // Close the SingleTodoPage
    }
  }
}
