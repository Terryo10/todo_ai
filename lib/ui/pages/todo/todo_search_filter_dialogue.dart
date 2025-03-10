import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/routes/router.gr.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/bloc/theme_bloc/theme_bloc.dart';
import '../../../static/app_colors.dart';

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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = themeState.appTheme == AppTheme.dark;

        // Define gradient colors based on theme
        final Color gradientStart =
            isDark ? AppColors.backgroundDark : Colors.white;
        final Color gradientEnd =
            isDark ? AppColors.backgroundDark2 : Colors.purple.shade50;

        final Color searchFieldColor = isDark
            ? colorScheme.surface.withOpacity(0.3)
            : Colors.purple.shade50.withOpacity(0.5);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientStart,
                  gradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search todos...',
                      hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6)),
                      prefixIcon:
                          Icon(Icons.search, color: colorScheme.primary),
                      filled: true,
                      fillColor: searchFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon:
                                  Icon(Icons.clear, color: colorScheme.primary),
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
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No todos found',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
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
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        final todo = _filteredTodos[index];
                        return InkWell(
                          onTap: () {
                            context.navigateTo(SingleTodoRoute(todo: todo));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(
                                todo.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
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
                                            ? colorScheme.primary
                                                .withOpacity(0.1)
                                            : isDark
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${todo.tasks.length} Tasks',
                                        style: TextStyle(
                                          color: todo.tasks.isNotEmpty
                                              ? colorScheme.primary
                                              : isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      todo.createdTime
                                          .toString()
                                          .substring(0, 10),
                                      style: TextStyle(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6),
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
                                color: todo.isCompleted
                                    ? Colors.green
                                    : colorScheme.onSurface.withOpacity(0.4),
                              ),
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
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
