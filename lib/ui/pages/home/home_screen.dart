import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_ai/routes/router.gr.dart';
import '../../../domain/bloc/theme_bloc/theme_bloc.dart';
import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/model/course.dart';
import '../../../domain/model/todo_model.dart';
import '../todo/create_todo_dialog.dart';
import '../todo/todo_search_filter_dialogue.dart';
import 'components/ai_todo_card.dart';
import 'components/todo_card_item.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Today', 'Important', 'Completed'];

  List<Todo> _filterTodos(List<Todo> todos) {
    switch (_selectedFilter) {
      case 'Today':
        return todos.where((todo) {
          // Check if todo has tasks due today
          return todo.tasks.any((task) =>
              task.reminderTime != null && _isToday(task.reminderTime!));
        }).toList();

      case 'Important':
        return todos
            .where((todo) => todo.tasks.any((task) => task.isImportant))
            .toList();

      case 'Completed':
        return todos
            .where((todo) =>
                todo.isCompleted ||
                todo.tasks.every((task) => task.isCompleted))
            .toList();

      case 'All':
      default:
        return todos;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AiTodoCard(
                          iconSrc: 'assets/icons/code.svg',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFilters(),
                      _buildTodoHeader(context),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: BlocBuilder<TodoBloc, TodoState>(
                    builder: (context, state) {
                      if (state is TodoLoaded) {
                        // Apply filter to todos
                        final filteredTodos = _filterTodos(state.todos);

                        if (filteredTodos.isEmpty) {
                          // Empty state
                          return SliverToBoxAdapter(
                            child: _buildEmptyState(context),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final todo = filteredTodos[index];
                              return KeyedSubtree(
                                key: ValueKey(todo.id),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TodoCardItem(todo: todo),
                                ),
                              );
                            },
                            childCount: filteredTodos.length,
                          ),
                        );
                      }
                      return SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .15,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await showDialog<bool>(
                context: context,
                builder: (context) => const CreateTodoDialog(),
              );
            },
            backgroundColor: colorScheme.primary,
            child: Icon(
              Icons.add,
              color: colorScheme.onPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Icon(
            Icons.assignment_outlined,
            size: 100,
            color: colorScheme.primary.withAlpha(179), // 0.7 opacity
          ),
          const SizedBox(height: 16),
          Text(
            'No todos found',
            style: theme.textTheme.titleLarge!.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onBackground.withAlpha(
                  153), // 0.6 opacity converted to alpha (0.6 * 255 ≈ 153)
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CreateTodoDialog(),
              );
            },
            icon: Icon(
              Icons.add,
              color: Colors.white, // Explicitly set icon color to white
            ),
            label: const Text('Create New Todo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor:
                  Colors.white, // Explicitly set text color to white
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'Today':
        return 'You don\'t have any tasks scheduled for today.\nTake a moment to plan your day.';
      case 'Important':
        return 'No important tasks found.\nMark tasks as important to see them here.';
      case 'Completed':
        return 'You haven\'t completed any tasks yet.\nKeep going, you\'re doing great!';
      case 'All':
      default:
        return 'Your todo list is empty.\nTap the button below to add a new task.';
    }
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello',
                style: theme.textTheme.headlineSmall!.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You have ${recentCourses.length} tasks pending',
                style:
                    TextStyle(color: colorScheme.onBackground.withOpacity(0.6)),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: colorScheme.onBackground),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TodoSearchFilterDialog(),
                  );
                },
              ),
              InkWell(
                onTap: () {
                  context.navigateTo(ProfileRoute());
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(
                        26), // 0.1 opacity converted to alpha (0.1 * 255 ≈ 26)
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/User.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              backgroundColor: theme.brightness == Brightness.dark
                  ? colorScheme.surface
                  : Colors.grey[200],
              selectedColor: colorScheme.primary.withAlpha(
                  51), // 0.2 opacity converted to alpha (0.2 * 255 ≈ 51)
              labelStyle: TextStyle(
                color:
                    isSelected ? colorScheme.primary : colorScheme.onBackground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodoHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "My Todos",
            style: theme.textTheme.headlineSmall!.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onBackground),
            color: colorScheme.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sort_date',
                child: Text(
                  'Sort by Date',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              PopupMenuItem(
                value: 'sort_priority',
                child: Text(
                  'Sort by Priority',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              PopupMenuItem(
                value: 'archive_completed',
                child: Text(
                  'Archive Completed',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'sort_date') {
                context.read<TodoBloc>().add(SortTodosByDate());
              } else if (value == 'sort_priority') {
                context.read<TodoBloc>().add(SortTodosByPriority());
              } else if (value == 'archive_completed') {
                context.read<TodoBloc>().add(ArchiveCompletedTodos());
              }
            },
          ),
        ],
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
