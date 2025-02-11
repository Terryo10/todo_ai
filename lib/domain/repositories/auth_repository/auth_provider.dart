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

  Future<void> loginWithGoogle()async{

  }

   Future<void> loginWithApple()async{

  }

   Future<void> loginWithFacebook()async{

  }

}
