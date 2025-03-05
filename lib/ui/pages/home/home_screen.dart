import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_ai/routes/router.gr.dart';
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
    return Scaffold(
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
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
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
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'You have ${recentCourses.length} tasks pending',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TodoSearchFilterDialog(),
                  );
                },
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/User.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor,
                      BlendMode.srcIn,
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
              backgroundColor: Colors.grey[200],
              selectedColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "My Todos",
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_date',
                child: Text('Sort by Date'),
              ),
              const PopupMenuItem(
                value: 'sort_priority',
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem(
                value: 'archive_completed',
                child: Text('Archive Completed'),
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

// Add this extension for shadow utilities
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
