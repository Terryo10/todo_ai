import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/bloc/todo_bloc/todo_bloc.dart';

class TodoSearchFilterDialog extends StatefulWidget {
  const TodoSearchFilterDialog({super.key});

  @override
  State<TodoSearchFilterDialog> createState() => _TodoSearchFilterDialogState();
}

class _TodoSearchFilterDialogState extends State<TodoSearchFilterDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Todo> _filteredTodos = [];
  List<Todo> _allTodos = [];

  @override
  void initState() {
    super.initState();
    final currentState = context.read<TodoBloc>().state;
    if (currentState is TodoLoaded) {
      _allTodos = currentState.todos;
      _filteredTodos = _allTodos;
    }
  }

  void _filterTodos(String query) {
    setState(() {
      _filteredTodos = _allTodos.where((todo) {
        final todoNameMatches =
            todo.name.toLowerCase().contains(query.toLowerCase());
        final taskNameMatches = todo.tasks.any(
            (task) => task.name.toLowerCase().contains(query.toLowerCase()));

        return todoNameMatches || taskNameMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search todos...',
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon:
                              const Icon(Icons.clear, color: Colors.deepPurple),
                          onPressed: () {
                            _searchController.clear();
                            _filterTodos('');
                          },
                        )
                      : null,
                ),
                onChanged: _filterTodos,
              ),
            ),
            if (_filteredTodos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.purple.shade200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No todos found',
                      style: TextStyle(
                        color: Colors.purple.shade300,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = _filteredTodos[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.shade100.withValues(alpha:0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          todo.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: todo.tasks.isNotEmpty
                                      ? Colors.purple.shade50
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${todo.tasks.length} Tasks',
                                  style: TextStyle(
                                    color: todo.tasks.isNotEmpty
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                todo.createdTime.toString().substring(0, 10),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Icon(
                          todo.isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: todo.isCompleted ? Colors.green : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
