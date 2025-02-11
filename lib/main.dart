import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_ai/firebase_options.dart';
import 'routes/router.dart';
import 'domain/app_blocs.dart';
import 'domain/app_repositories.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  final appRouter = AppRouter();
  const FlutterSecureStorage storage = FlutterSecureStorage();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
