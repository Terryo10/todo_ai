import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'routes/router.dart';
import 'state/app_blocs.dart';
import 'state/app_repositories.dart';

void main() {
  final appRouter = AppRouter();
  const FlutterSecureStorage storage = FlutterSecureStorage();
  //firebase for notifications

  // Configure app
  var appConfig = AppRepositories(
    storage: storage,
    appBlocs: AppBlocs(
      storage: storage,
      app: MyApp(
        appRouter: appRouter,
      ),
    ),
  );

  runApp(appConfig);
}

class MyApp extends StatefulWidget {
  final AppRouter appRouter;
  const MyApp({
    super.key,
    required this.appRouter,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Todo AI',
      routerDelegate: widget.appRouter.delegate(),
      routeInformationParser: widget.appRouter.defaultRouteParser(),
    );
  }
}
