import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:todo_ai/ui/pages/todo/add_task_dialogue.dart';
import 'package:todo_ai/ui/pages/todo/todo_card.dart';

import '../../../domain/bloc/auth_bloc/auth_bloc.dart';
import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/model/todo_model.dart';

@RoutePage()
class TodoScreenPage extends StatefulWidget {
  const TodoScreenPage({super.key});

  @override
  State<TodoScreenPage> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreenPage> {
  bool showCompleted = true;

  @override
  void initState() {
    super.initState();
    // Load todos when screen opens
    context.read<TodoBloc>().add(LoadTodos());
  }

  Future<void> _showCreateTodoDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateTodoDialog(),
    );

    if (result == true && context.mounted) {
      // Reload todos after creating new one
      context.read<TodoBloc>().add(LoadTodos());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TodoError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is TodoLoaded) {
            final uncompletedTodos =
                state.todos.where((todo) => !todo.isCompleted).toList();
            final completedTodos =
                state.todos.where((todo) => todo.isCompleted).toList();

            return CustomScrollView(
              slivers: [
                // Uncompleted Todos
                if (uncompletedTodos.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Active Todos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => TodoCard(
                      todo: uncompletedTodos[index],
                    ),
                    childCount: uncompletedTodos.length,
                  ),
                ),

                // Completed Todos
                if (completedTodos.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            'Completed Todos',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(showCompleted
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                showCompleted = !showCompleted;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                if (completedTodos.isNotEmpty && showCompleted)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => TodoCard(
                        todo: completedTodos[index],
                      ),
                      childCount: completedTodos.length,
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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

class CreateTodoTaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const CreateTodoTaskListItem({
    super.key,
    required this.task,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.assignedTo != null) Text('Assigned to: ${task.assignedTo}'),
          if (task.reminderTime != null)
            Text(
                'Reminder: ${DateFormat.yMMMd().add_jm().format(task.reminderTime!)}'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
      leading:
          task.isImportant ? const Icon(Icons.star, color: Colors.amber) : null,
    );
  }
}
