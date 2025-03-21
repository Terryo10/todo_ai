import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_ai/domain/bloc/edit_profile_bloc/edit_profile_bloc.dart';
import 'package:todo_ai/domain/bloc/prompt_generator_bloc/prompt_generator_bloc.dart';
import 'package:todo_ai/domain/repositories/todo_repository/todo_provider.dart';
import 'package:todo_ai/domain/repositories/todo_repository/todo_repository.dart';

import 'bloc/settings_bloc/settings_bloc.dart';
import 'bloc/subscription_bloc/subscription_bloc.dart';
import 'bloc/theme_bloc/theme_bloc.dart';
import 'bloc/todo_bloc/todo_bloc.dart';
import 'repositories/auth_repository/auth_repository.dart';
import 'repositories/cache_repository/cache_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/cache_bloc/cache_bloc.dart';
import 'services/notification_service.dart';
import 'services/subscription_service.dart';

class AppBlocs extends StatelessWidget {
  final Widget app;
  final FlutterSecureStorage storage;
  final FirebaseFirestore firestore;
  const AppBlocs(
      {super.key,
      required this.app,
      required this.storage,
      required this.firestore});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(storage: storage)..add(ThemeLoaded()),
        ),
        BlocProvider(
          create: (context) => CacheBloc(
            cacheRepository: RepositoryProvider.of<CacheRepository>(context),
          )..add(
              AppStarted(),
            ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            cacheBloc: BlocProvider.of<CacheBloc>(context),
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          )..add(
              CheckAuthStatus(),
            ),
        ),
        BlocProvider(
          create: (context) => TodoBloc(
              repository: RepositoryProvider.of<TodoRepository>(context),
              authBloc: BlocProvider.of<AuthBloc>(context),
              notificationService:
                  RepositoryProvider.of<NotificationService>(context))
            ..add(LoadTodos()),
        ),
        BlocProvider(
          create: (context) => SubscriptionBloc(
            subscriptionService: SubscriptionService(firestore: firestore),
          ),
        ),
        BlocProvider(
          create: (context) => PromptGeneratorBloc(
            BlocProvider.of<AuthBloc>(context),
            todoProvider: TodoProvider(),
            subscriptionBloc: BlocProvider.of<SubscriptionBloc>(context),
          ),
        ),
        BlocProvider(
          create: (context) => EditProfileBloc(
            RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(
            RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
      ],
      child: app,
    );
  }
}
