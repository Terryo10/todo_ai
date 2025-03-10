import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:todo_ai/domain/model/todo_model.dart';
import 'package:todo_ai/firebase_options.dart';
import 'domain/bloc/theme_bloc/theme_bloc.dart';
import 'domain/repositories/todo_repository/todo_repository.dart';
import 'domain/services/notification_service.dart';
import 'routes/router.dart';
import 'domain/app_blocs.dart';
import 'domain/app_repositories.dart';
import 'static/app_colors.dart';
import 'package:uni_links/uni_links.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to do database operations in the background, initialize Firebase first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  debugPrint("Handling a background message: ${message.messageId}");
  // You can perform background operations here, like updating the database
}

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
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
  StreamSubscription? _linkSubscription;
  @override
  void initState() {
    super.initState();
    initialization();
    _initDeepLinkHandling();
    _initializeNotifications();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: 'Todo AI',
          theme: AppThemeData.lightTheme(),
          darkTheme: AppThemeData.darkTheme(),
          themeMode: themeState.themeMode,
          routerDelegate: widget.appRouter.delegate(),
          routeInformationParser: widget.appRouter.defaultRouteParser(),
        );
      },
    );
  }

    void _initializeNotifications() async {
    final notificationService = context.read<NotificationService>();
    await notificationService.initialize(
      onBackgroundMessage: _firebaseMessagingBackgroundHandler,
      onMessageOpenedApp: (RemoteMessage message) {
        debugPrint('Message opened app: ${message.notification?.title}');
        // Handle navigation based on message data
        final data = message.data;
        if (data.containsKey('todoId')) {
          final todoId = data['todoId'];
          widget.appRouter.navigateNamed('/todo/$todoId');
        }
      },
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinkHandling() async {
    // Handle app opened from a link
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } on PlatformException {
      // Error handling
      debugPrint('Failed to get initial link');
    }

    // Handle links when app is already running
    _linkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      debugPrint('Error in deep link stream: $err');
    });
  }

  void _handleDeepLink(String link) {
    debugPrint('Received deep link: $link');

    // Parse the link and extract the invitation code
    Uri uri = Uri.parse(link);

    if (uri.path == '/join' && uri.queryParameters.containsKey('code')) {
      String invitationCode = uri.queryParameters['code']!;

      // Navigate to the join screen with the code as a query parameter
      // The route will handle the nullable parameter
      widget.appRouter.navigateNamed('/join?code=$invitationCode');
    } else {
      // Navigate to the join screen without a code
      // This will show an error to the user
      widget.appRouter.navigateNamed('/join');
    }
  }
}
