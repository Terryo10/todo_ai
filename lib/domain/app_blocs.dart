import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_ai/domain/bloc/prompt_generator_bloc/prompt_generator_bloc.dart';
import 'package:todo_ai/domain/repositories/todo_repository/todo_provider.dart';
import 'package:todo_ai/domain/repositories/todo_repository/todo_repository.dart';

import 'bloc/todo_bloc/todo_bloc.dart';
import 'repositories/auth_repository/auth_repository.dart';
import 'repositories/cache_repository/cache_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/cache_bloc/cache_bloc.dart';

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
          )..add(LoadTodos()),
        ),
        BlocProvider(
          create: (context) => PromptGeneratorBloc(
            todoProvider: TodoProvider(),
          ),
        ),
      ],
      child: app,
    );
  }
}
