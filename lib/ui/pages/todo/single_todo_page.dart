import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/model/todo_model.dart';
import 'add_task_dialogue.dart';

class SingleTodoPage extends StatefulWidget {
  final Todo todo;

  const SingleTodoPage({
    super.key,
    required this.todo,
  });

  @override
  _SingleTodoPageState createState() => _SingleTodoPageState();
}

class _SingleTodoPageState extends State<SingleTodoPage> {
  bool _isPendingExpanded = true;
  bool _isCompletedExpanded = false;

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
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
            backgroundColor: const Color(0xFF6B4EFF),
            onPressed: () => _showAddTaskDialog(context, currentTodo),
            child: const Icon(Icons.add, color: Colors.white),
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
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black,
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

  // Widget _buildTasksSection(
  //     BuildContext context, Todo todo, List<Task> tasks, String sectionTitle) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         sectionTitle,
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: tasks.length,
  //         itemBuilder: (context, index) {
  //           return _buildTaskItem(context, todo, tasks[index]);
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTaskItem(BuildContext context, Todo todo, Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: const Color(0xFF6B4EFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(
            color: Colors.grey.shade300,
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
          style: TextStyle(
            color: Colors.black,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.assignedTo != null)
              Text(
                'Assigned to: ${task.assignedTo!}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            if (task.reminderTime != null)
              Text(
                'Reminder: ${DateFormat.yMMMd().add_jm().format(task.reminderTime!)}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
          ],
        ),
        trailing: task.isImportant
            ? const Icon(Icons.star, color: Colors.amber, size: 20)
            : null,
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String text, IconData icon) {
    return PopupMenuItem(
      value: text,
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoHeader(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Checkbox(
                value: todo.isCompleted,
                activeColor: const Color(0xFF6B4EFF),
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
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.black54),
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
    // Will impliment editing code here
    // final updatedTodo = await showDialog<Todo>(
    //   context: context,
    //   // builder: (context) => EditTodoDialog(todo: todo),
    // );

    // if (updatedTodo != null && context.mounted) {
    //   context.read<TodoBloc>().add(UpdateTodo(todo: updatedTodo));
    // }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Todo todo) async {
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
