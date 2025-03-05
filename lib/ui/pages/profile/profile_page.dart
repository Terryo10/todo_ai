import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo_ai/domain/bloc/auth_bloc/auth_bloc.dart';
import 'package:todo_ai/domain/bloc/todo_bloc/todo_bloc.dart';

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
                      color: Colors.black.withValues(alpha: 0.1),
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
          onPressed: () async {
            await showDialog<bool>(
              context: context,
              builder: (context) => const EditProfileDialog(),
            );
          },
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

class ProfileInfoItem {
  final String title;
  final String value;
  final IconData icon;

  const ProfileInfoItem(this.title, this.value, this.icon);
}
