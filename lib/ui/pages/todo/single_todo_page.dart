import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/model/todo_model.dart';
import '../../../domain/services/invitation_service.dart';
import '../../../routes/router.gr.dart';
import '../../../static/app_colors.dart';
import 'add_task_dialogue.dart';
import 'edit_todo_dialogue.dart';
import 'widgets/assignee_chip.dart';
import 'widgets/collaborators_dialogue.dart';
import 'widgets/share_todo_button.dart';
import 'widgets/task_asignment.dart';

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

        final completionPercentage = currentTodo.tasks.isEmpty
            ? 0.0
            : (completedTasks.length / currentTodo.tasks.length) * 100;

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
              // Add ShareTodoButton
              ShareTodoButton(
                  todoId: currentTodo.id,
                  invitationService:
                      RepositoryProvider.of<InvitationService>(context)),
              IconButton(
                icon:
                    Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                onPressed: () => _showEditTodoDialog(context, currentTodo),
              ),
              IconButton(
                icon:
                    Icon(Icons.delete_outline, color: theme.colorScheme.error),
                onPressed: () => _showDeleteConfirmation(context, currentTodo),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildCompactHeader(
                          context, currentTodo, completionPercentage),
                      // Add collaborator list
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        showCollaboratorsDialog(context, currentTodo),
                    icon: const Icon(
                      Icons.people,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text('View Collaborators'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryLight,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              // Pending Tasks Section
              if (pendingTasks.isNotEmpty)
                _buildTasksSection(
                  context,
                  currentTodo,
                  pendingTasks,
                  'Pending Tasks',
                  _isPendingExpanded,
                  () =>
                      setState(() => _isPendingExpanded = !_isPendingExpanded),
                  theme.colorScheme.tertiary,
                ),

              // Spacing between sections
              if (pendingTasks.isNotEmpty && completedTasks.isNotEmpty)
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Completed Tasks Section
              if (completedTasks.isNotEmpty)
                _buildTasksSection(
                  context,
                  currentTodo,
                  completedTasks,
                  'Completed Tasks',
                  _isCompletedExpanded,
                  () => setState(
                      () => _isCompletedExpanded = !_isCompletedExpanded),
                  theme.colorScheme.secondary,
                ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: theme.colorScheme.primary,
            onPressed: () => _showAddTaskDialog(context, currentTodo),
            elevation: 4,
            child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
          ),
        );
      },
    );
  }

  Widget _buildTasksSection(
    BuildContext context,
    Todo todo,
    List<Task> tasks,
    String sectionTitle,
    bool isExpanded,
    VoidCallback onToggle,
    Color accentColor,
  ) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sectionTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              ...tasks.map((task) => _buildTaskItem(context, todo, task)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Todo todo, Task task) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final canManageTasks =
        currentUserId == todo.uid || todo.collaborators.contains(currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.white
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Checkbox(
              value: task.isCompleted,
              activeColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(
                color: theme.colorScheme.outline,
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? theme.colorScheme.onSurface.withOpacity(0.6)
                    : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Replace the existing assignedTo text with AssigneeChip
                if (task.assignedTo != null || canManageTasks) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AssigneeChip(
                        assigneeId: task.assignedTo,
                        showUnassigned: canManageTasks,
                        onTap: canManageTasks
                            ? () {
                                // Show assignment dialog
                                showTaskAssignmentDialog(
                                  context,
                                  todoId: todo.id,
                                  taskId: task.id,
                                  taskName: task.name,
                                  currentAssignee: task.assignedTo,
                                  collaborators: [
                                    ...todo.collaborators,
                                    todo.uid
                                  ],
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
                if (task.reminderTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat.yMMMd().add_jm().format(task.reminderTime!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: task.isImportant
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                  )
                : null,
          ),
        ),
      ),
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
    final updatedTodo = await showDialog<Todo>(
      context: context,
      builder: (context) => EditTodoDialog(todo: todo),
    );

    if (updatedTodo != null && context.mounted) {
      context.read<TodoBloc>().add(UpdateTodo(todo: updatedTodo));
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Todo todo) async {
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Todo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.error,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${todo.name}"? This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<TodoBloc>().add(DeleteTodo(todoId: todo.id));
      Navigator.of(context).pop(); // Close the SingleTodoPage
    }
  }

  Widget buildCompactHeader(
      BuildContext context, Todo todo, double completionPercentage) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.primary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and checkbox row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  todo.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Checkbox(
                value: todo.isCompleted,
                activeColor: Colors.white,
                checkColor: theme.colorScheme.primary,
                side: BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
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

          // Progress bar
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Progress: ${completionPercentage.toInt()}%',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimary,
              ),
              minHeight: 6,
            ),
          ),

          // Stats row
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Created date chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat.yMMMd().format(todo.createdTime),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Total tasks chip
              _buildStatusChip(
                context,
                'Total: ${todo.tasks.length}',
                Icons.assignment,
                theme.colorScheme.onPrimary.withOpacity(0.2),
                theme.colorScheme.onPrimary,
              ),

              // Pending tasks chip
              _buildStatusChip(
                context,
                'Pending: ${todo.tasks.where((t) => !t.isCompleted).length}',
                Icons.hourglass_empty,
                theme.colorScheme.onPrimary.withOpacity(0.2),
                theme.colorScheme.onPrimary,
              ),

              // Completed tasks chip
              _buildStatusChip(
                context,
                'Done: ${todo.tasks.where((t) => t.isCompleted).length}',
                Icons.check_circle_outline,
                theme.colorScheme.onPrimary.withOpacity(0.2),
                theme.colorScheme.onPrimary,
              ),

              // Collaborators button
              InkWell(
                onTap: () => showCollaboratorsDialog(context, todo),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${todo.collaborators.length} Members',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String title,
    IconData icon,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
