import 'repositories/auth_repository/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'repositories/auth_repository/auth_repository.dart';
import 'repositories/cache_repository/cache_repository.dart';

class AppRepositories extends StatelessWidget {
  final Widget appBlocs;
  final FlutterSecureStorage storage;
  const AppRepositories({
    super.key,
    required this.appBlocs,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(
            storage: storage,
            authProvider: AuthProvider(
              storage: storage,
            ),
          ),
        ),
        RepositoryProvider(
          create: (context) => CacheRepository(storage: storage),
        )
      ],
      child: appBlocs,
    );
  }
}
