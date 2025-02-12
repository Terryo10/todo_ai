import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_ai/domain/model/user_model.dart';

import 'auth_provider.dart';

class AuthRepository {
  final AuthProvider authProvider;
  FlutterSecureStorage storage;

  AuthRepository({required this.storage, required this.authProvider});

  Future<void> logOut() async {
    await storage.deleteAll();
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<UserModel?> loginWithGoogle() async {
    return await authProvider.signInWithGoogle();
  }

  Future<UserModel?> loginWithFacebook() async {
    return await authProvider.signInWithFacebook();
  }

  Future<UserModel?> loginWithApple() async {
    return await authProvider.signInWithApple();
  }
}
