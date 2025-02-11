import 'dart:convert';

import '../../../static/app_urls.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthProvider {
  final FlutterSecureStorage storage;

  AuthProvider({required this.storage});

  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> logOut() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse(AppUrls.logout),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      await storage.deleteAll();
    }
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.login),
        body: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String identifier,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.register),
        body: {
          'name': name,
          'identifier': identifier,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.verifyOtp),
        body: {
          'phone': phone,
          'otp': otp,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> forgotPassword(String identifier) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.forgotPassword),
        body: {
          'identifier': identifier,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.resetPassword),
        body: {
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
