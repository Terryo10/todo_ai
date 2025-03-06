import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:todo_ai/domain/model/todo_model.dart';
import 'package:todo_ai/firebase_options.dart';
import 'domain/repositories/todo_repository/todo_repository.dart';
import 'routes/router.dart';
import 'domain/app_blocs.dart';
import 'domain/app_repositories.dart';

void main() async {
  try {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    final appRouter = AppRouter();
    const FlutterSecureStorage storage = FlutterSecureStorage();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final todoBox = await TodoRepository.init().catchError((error) {
      debugPrint('Error initializing Hive: $error');
      return Hive.openBox<Todo>('todos');
    });

    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn;

    if (Platform.isIOS) {
      googleSignIn = GoogleSignIn(
          clientId:
              '446296947297-sj6cb653v4gu7p82ejqhqsakokl9raoq.apps.googleusercontent.com');
    } else {
      googleSignIn = GoogleSignIn();
    }

    final FacebookAuth facebookAuth = FacebookAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Configure app
    var appConfig = AppRepositories(
      facebookAuth: facebookAuth,
      firebaseAuth: firebaseAuth,
      firestore: firestore,
      googleSignIn: googleSignIn,
      storage: storage,
      todoBox: todoBox,
      appBlocs: AppBlocs(
        firestore: firestore,
        storage: storage,
        app: MyApp(
          appRouter: appRouter,
        ),
      ),
    );

    runApp(appConfig);
  } catch (e, stackTrace) {
    debugPrint('Error in main: $e');
    debugPrint(stackTrace.toString());
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
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
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Todo AI',
      routerDelegate: widget.appRouter.delegate(),
      routeInformationParser: widget.appRouter.defaultRouteParser(),
    );
  }
}
