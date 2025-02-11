import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<void> loginWithGoogle()async {
    await authProvider.loginWithGoogle();
  }
}
