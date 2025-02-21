import 'dart:convert';

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

  Future<void> saveUserToStorage(UserModel user) async {
    await storage.write(key: 'user', value: user.toString());
  }

  Future<UserModel?> getUserFromStorage() async {
    return jsonDecode(await storage.read(key: 'user') ?? '');
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

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Failed to login with Google';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw 'Failed to login with Google';
      }

      final user = _userFromFirebase(userCredential.user!, 'google');

      await _saveUserToFirestore(user);
      await saveUserToStorage(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw 'FirebaseAuthException: ${e.code} - ${e.message}';
    } catch (e) {
      throw 'Failed to login with Google: $e';
    }
  }

 Future<UserModel> signInWithApple() async {
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

    final userCredential = await firebaseAuth.signInWithCredential(oauthCredential);
    
    // Check if we got a name from Apple
    String? displayName;
    if (appleCredential.givenName != null && appleCredential.familyName != null) {
      displayName = '${appleCredential.givenName} ${appleCredential.familyName}';
      
      // Store the name in Firestore since Apple only provides it once
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'displayName': displayName,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // Try to get the stored name from Firestore
      final userDoc = await firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists) {
        displayName = userDoc.data()?['displayName'];
      }
    }

    final now = DateTime.now();

    final user = UserModel(
      uid: userCredential.user!.uid,
      email: userCredential.user!.email ?? '',
      displayName: displayName ?? 'Apple User',
      provider: 'apple',
      createdAt: now,
      lastLoginAt: now, 

    );

    await _saveUserToFirestore(user);
    await saveUserToStorage(user);
    return user;
  } catch (e) {
    throw (e.toString());
  }
}

  Future<UserModel> signInWithFacebook() async {
    try {
      final LoginResult result = await facebookAuth.login();

      if (result.status != LoginStatus.success) {
        throw (result.message ?? '');
      }

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) throw (result.message ?? '');

      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) throw (result.message ?? '');

      final user = _userFromFirebase(userCredential.user!, 'facebook');
      await _saveUserToFirestore(user);
      return user;
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<void> logOut() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        await firestore.collection('users').doc(currentUser.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
      }

      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
        facebookAuth.logOut(),
      ]);
    } catch (e) {
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
