import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo_ai/domain/bloc/auth_bloc/auth_bloc.dart';
import 'package:todo_ai/domain/bloc/todo_bloc/todo_bloc.dart';

import '../../../domain/model/todo_model.dart';
import '../../../routes/router.gr.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              context.navigateTo(SettingsRoute());
            },
          ),
        ],
      ),
      body: getBody(context),
    );
  }

  Widget getBody(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _ProfileHeader(),
              const SizedBox(height: 24),
              _ActionButtons(),
              const SizedBox(height: 24),
              const _ProfileInfoCards(),
              const SizedBox(height: 24),
              const _RecentActivity(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticatedState) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset(
                    'assets/icons/User.svg',
                    width: 75,
                    height: 75,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticatedState) {
                    return Text(
                      state.displayName,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return Container();
                },
              ),
              const SizedBox(height: 4),
              Text(
                state.email,
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.userId,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        return Column();
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text("Edit Profile"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        OutlinedButton.icon(
          onPressed: () {
            context.navigateTo(HomeRoute());
          },
          icon: const Icon(Icons.list_alt_rounded),
          label: const Text("My Todos"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoCards extends StatelessWidget {
  const _ProfileInfoCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the TodoBloc state here where context is available
    final todoState = context.read<TodoBloc>().state;
    String usersTodos = '0';

    if (todoState is TodoLoaded) {
      // Set usersTodos based on loaded state
      usersTodos = todoState.todos.length.toString();
    }

    // Create the items list here with the dynamic data
    final List<ProfileInfoItem> items = [
      const ProfileInfoItem("Account Type", 'Free', Icons.person),
      ProfileInfoItem("Todos", usersTodos, Icons.check_circle),
      const ProfileInfoItem("Collaborators", '0', Icons.people),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _InfoCard(items[index]);
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ProfileInfoItem item;

  const _InfoCard(this.item);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              item.value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the TodoBloc state to get todos
    final todoState = context.watch<TodoBloc>().state;

    // Create a list to hold todos
    List<Todo> recentTodos = [];

    // Check if todos are loaded
    if (todoState is TodoLoaded) {
      // Get all todos
      final allTodos = todoState.todos;

      // Sort todos by creation time (newest first)
      final sortedTodos = List<Todo>.from(allTodos)
        ..sort((a, b) => b.createdTime.compareTo(a.createdTime));

      // Take the 5 most recent todos
      recentTodos = sortedTodos.take(5).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            "Recent Activity",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        if (recentTodos.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text("No recent todos found"),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTodos.length,
            itemBuilder: (context, index) {
              final todo = recentTodos[index];
              final completedTasks =
                  todo.tasks.where((t) => t.isCompleted).length;
              final totalTasks = todo.tasks.length;

              // Calculate how long ago the todo was created
              final now = DateTime.now();
              final difference = now.difference(todo.createdTime);
              String timeAgo;

              if (difference.inDays > 0) {
                timeAgo =
                    "${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago";
              } else if (difference.inHours > 0) {
                timeAgo =
                    "${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago";
              } else if (difference.inMinutes > 0) {
                timeAgo =
                    "${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago";
              } else {
                timeAgo = "Just now";
              }

              return _ActivityItem(
                title: todo.name,
                todo: todo,
                subtitle:
                    "$completedTasks of $totalTasks tasks completed • $timeAgo",
                icon:
                    todo.isCompleted ? Icons.task_alt : Icons.checklist_rounded,
                isCompleted: todo.isCompleted,
              );
            },
          ),
      ],
    );
  }
}

// Update the ActivityItem class to include completion status
class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Todo todo;

  final IconData icon;
  final bool isCompleted;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.todo,
    required this.icon,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon, color: Colors.white),
          backgroundColor:
              isCompleted ? Colors.green : Theme.of(context).primaryColor,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.navigateTo(
            SingleTodoRoute(
              todo: todo,
            ),
          );
        },
      ),
    );
  }
}

class ProfileInfoItem {
  final String title;
  final String value;
  final IconData icon;

  const ProfileInfoItem(this.title, this.value, this.icon);
}
