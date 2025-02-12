import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import '../../model/user_model.dart';

class AuthProvider {
  final FlutterSecureStorage storage;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;
  final FirebaseFirestore firestore;

  AuthProvider({
    required this.storage,
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.facebookAuth,
    required this.firestore,
  });

  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  UserModel _userFromFirebase(User user, String provider) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      provider: provider,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) return null;

      final user = _userFromFirebase(userCredential.user!, 'google');
      await _saveUserToFirestore(user);
      return user;
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(oauthCredential);
      if (userCredential.user == null) return null;

      // For Apple Sign In, we need to handle the display name specially
      // because it's only provided on the first sign-in
      String? displayName;
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
      }

      final user = _userFromFirebase(userCredential.user!, 'apple');
      await _saveUserToFirestore(user);
      return user;
    } catch (e) {
      print('Apple sign in error: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithFacebook() async {
    try {
      final LoginResult result = await facebookAuth.login();

      if (result.status != LoginStatus.success) {
        return null;
      }

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) return null;

      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) return null;

      final user = _userFromFirebase(userCredential.user!, 'facebook');
      await _saveUserToFirestore(user);
      return user;
    } catch (e) {
      print('Facebook sign in error: $e');
      rethrow;
    }
  }

  Future<void> logOut() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        // Update last login time before logging out
        await firestore.collection('users').doc(currentUser.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
      }

      // Sign out from all providers
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
        facebookAuth.logOut(),
      ]);
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    // Note: In a real app, you might want to fetch the provider
    // information from Firestore instead of defaulting to 'firebase'
    return _userFromFirebase(user, 'firebase');
  }

  // Stream of auth state changes
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _userFromFirebase(user, 'firebase');
    });
  }

    Future<void> _saveUserToFirestore(UserModel user) async {
    await firestore.collection('users').doc(user.uid).set(
      user.toMap(),
      SetOptions(merge: true),
    );
  }
}
