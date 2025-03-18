import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

import 'model/todo_model.dart';
import 'repositories/auth_repository/auth_provider.dart' as authy;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'repositories/auth_repository/auth_repository.dart';
import 'repositories/cache_repository/cache_repository.dart';
import 'repositories/todo_repository/todo_repository.dart';
import 'services/invitation_service.dart';
import 'services/notification_service.dart';

class AppRepositories extends StatelessWidget {
  final Widget appBlocs;
  final FlutterSecureStorage storage;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;
  final FirebaseFirestore firestore;
  final Box<Todo> todoBox;

  const AppRepositories({
    super.key,
    required this.appBlocs,
    required this.storage,
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.facebookAuth,
    required this.firestore,
    required this.todoBox,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(
            storage: storage,
            authProvider: authy.AuthProvider(
              storage: storage,
              facebookAuth: facebookAuth,
              firebaseAuth: firebaseAuth,
              firestore: firestore,
              googleSignIn: googleSignIn,
            ),
          ),
        ),
        RepositoryProvider(
          create: (context) => CacheRepository(storage: storage),
        ),
        RepositoryProvider(
          create: (context) => TodoRepository(
            firestore: firestore,
            todoBox: todoBox,
            connectivity: Connectivity(),
          ),
        ),
        RepositoryProvider<InvitationService>(
          create: (context) => InvitationService(
            firestore: firestore,
            auth: firebaseAuth,
          ),
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => NotificationService(
            firestore: firestore,
            auth: firebaseAuth,
          ),
        ),
      ],
      child: appBlocs,
    );
  }
}
