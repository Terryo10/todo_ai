import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/bloc/auth_bloc/auth_bloc.dart';
import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/model/todo_model.dart';
import 'add_task_dialogue.dart';
import 'task_item.dart';

class CreateTodoDialog extends StatefulWidget {
  const CreateTodoDialog({super.key});

  @override
  State<CreateTodoDialog> createState() => _CreateTodoDialogState();
}

class _CreateTodoDialogState extends State<CreateTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _collaborators = [];
  final List<Task> _tasks = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showAddTaskDialog() async {
    final temporaryTodoId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

    final task = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(todoId: temporaryTodoId),
    );

    if (task != null) {
      setState(() {
        _tasks.add(task);
      });
    }
  }

  Future<void> _showAddCollaboratorDialog() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => const AddCollaboratorDialog(),
    );

    if (email != null && email.isNotEmpty) {
      setState(() {
        _collaborators.add(email);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Todo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Todo Name',
                  hintText: 'Enter todo name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tasks Section
              if (_tasks.isNotEmpty) ...[
                const Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._tasks.map((task) => CreateTodoTaskListItem(
                      task: task,
                      onDelete: () {
                        setState(() {
                          _tasks.remove(task);
                        });
                      },
                    )),
                const SizedBox(height: 8),
              ],

              // Add Task Button
              Center(
                child: TextButton.icon(
                  onPressed: _showAddTaskDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ),

              const SizedBox(height: 16),

              // Collaborators Section
              const Text(
                'Collaborators',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._collaborators.map((email) => Chip(
                        label: Text(email),
                        onDeleted: () {
                          setState(() {
                            _collaborators.remove(email);
                          });
                        },
                      )),
                  ActionChip(
                    avatar: const Icon(Icons.add),
                    label: const Text('Add Collaborator'),
                    onPressed: _showAddCollaboratorDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticatedState) {
              return ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Create the todo
                    context.read<TodoBloc>().add(AddTodo(
                          name: _nameController.text,
                        ));

                    // Add tasks after todo is created
                    if (_tasks.isNotEmpty) {
                      context.read<TodoBloc>().stream.listen((state) {
                        if (state is TodoLoaded) {
                          final newTodo = state.todos.firstWhere(
                            (todo) => todo.name == _nameController.text,
                            orElse: () => throw Exception('Todo not found'),
                          );

                          for (final task in _tasks) {
                            context.read<TodoBloc>().add(AddTask(
                                  todoId: newTodo.id,
                                  taskName: task.name,
                                  assignedTo: task.assignedTo,
                                  reminderTime: task.reminderTime,
                                  isImportant: task.isImportant,
                                ));
                          }
                        }
                      });
                    }

                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Create'),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }
}
