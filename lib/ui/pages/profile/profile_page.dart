import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo_ai/domain/bloc/edit_profile_bloc/edit_profile_bloc.dart';
import 'package:todo_ai/domain/bloc/todo_bloc/todo_bloc.dart';

import '../../../domain/bloc/auth_bloc/auth_bloc.dart';
import '../../../routes/router.gr.dart';
import 'edit_profile_dialog.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticatedState) {
      context.read<EditProfileBloc>().add(GetProfile(
            userId: authState.userId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: theme.colorScheme.onBackground),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocListener<EditProfileBloc, EditProfileState>(
      listener: (context, state) {},
      child: BlocBuilder<EditProfileBloc, EditProfileState>(
        builder: (context, state) {
          if (state is EditProfileLoadedState) {
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.surface,
                    child: SvgPicture.asset(
                      'assets/icons/User.svg',
                      width: 75,
                      height: 75,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  state.user.displayName ?? '',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.user.email ?? '',
                  style: textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            );
          } else if (state is EditProfileLoadingState) {
            // Skeleton loading state
            return Column(
              children: [
                // Avatar skeleton loader
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.brightness == Brightness.light
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                // Name skeleton loader
                Container(
                  width: 200,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                // Email skeleton loader
                Container(
                  width: 240,
                  height: 18,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          }

          return const Column();
        },
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            await showDialog<bool>(
              context: context,
              builder: (context) => const EditProfileDialog(),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text("Edit Profile"),
          style: ElevatedButton.styleFrom(
            foregroundColor: theme.colorScheme.onPrimary,
            backgroundColor: theme.colorScheme.primary,
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
          icon: Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary),
          label: Text("My Todos",
              style: TextStyle(color: theme.colorScheme.primary)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.primary),
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
  const _ProfileInfoCards();

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
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              item.value.toString(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
