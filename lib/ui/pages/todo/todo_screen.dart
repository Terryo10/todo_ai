import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:todo_ai/ui/pages/todo/todo_card.dart';
import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import 'create_todo_dialog.dart';

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
