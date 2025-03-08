import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_ai/domain/model/user_model.dart';

import '../../model/settings_model.dart';
import 'auth_provider.dart';

class AuthRepository {
  final AuthProvider authProvider;
  FlutterSecureStorage storage;

  AuthRepository({required this.storage, required this.authProvider});

  Stream<UserModel?> get authStateChanges => authProvider.authStateChanges;

  UserModel? getCurrentUser() => authProvider.getCurrentUser();

  Future<void> logOut() async {
    await storage.deleteAll();
    await authProvider.logOut();
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<UserModel> loginWithGoogle() async {
    return await authProvider.signInWithGoogle();
  }

  Future<UserModel> editProfile(
      {required String userId, required String displayName}) async {
    return await authProvider.editProfile(
        userId: userId, displayName: displayName);
  }

  Future<SettingsModel> saveSettings(
      {required String userId,
      required bool isDarkMode,
      required bool isSilenceMode,
      required bool isVibrationMode}) async {
    return await authProvider.saveSettings(
        userId: userId,
        isDarkMode: isDarkMode,
        isSilenceMode: isSilenceMode,
        isVibrationMode: isVibrationMode);
  }

  Future<UserModel> getProfile({required String userId}) async {
    return await authProvider.getProfile(userId: userId);
  }

  Future<SettingsModel> getSettings({required String userId}) async {
    return await authProvider.getSettings(userId: userId);
  }

  Future<UserModel> loginWithApple() async {
    return await authProvider.signInWithApple();
  }
}
