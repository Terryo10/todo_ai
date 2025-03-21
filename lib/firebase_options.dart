// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAaFI5hutycONvzsb5TGJxYBvj_zymdoIw',
    appId: '1:446296947297:web:674ab644e1cd93f4d90820',
    messagingSenderId: '446296947297',
    projectId: 'taskwhiz-11cbf',
    authDomain: 'taskwhiz-11cbf.firebaseapp.com',
    storageBucket: 'taskwhiz-11cbf.firebasestorage.app',
    measurementId: 'G-XDE4BBH49N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_mf_gohPfREpzpTAitSACmHo7WBFfQm0',
    appId: '1:446296947297:android:441b06db2f2e94c3d90820',
    messagingSenderId: '446296947297',
    projectId: 'taskwhiz-11cbf',
    storageBucket: 'taskwhiz-11cbf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsMmAWAy2SnE03YcKh7wRQX7J_P54Ggaw',
    appId: '1:446296947297:ios:da79dbeb0f02df5bd90820',
    messagingSenderId: '446296947297',
    projectId: 'taskwhiz-11cbf',
    storageBucket: 'taskwhiz-11cbf.firebasestorage.app',
    androidClientId: '446296947297-a3fdgobmq66fi092po8noajts7tb87jb.apps.googleusercontent.com',
    iosClientId: '446296947297-ta2oo4qjj4dq5d2hntlhd2rhe9hd566u.apps.googleusercontent.com',
    iosBundleId: 'com.taskwhiz.todoai',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAsMmAWAy2SnE03YcKh7wRQX7J_P54Ggaw',
    appId: '1:446296947297:ios:0ffeb9f980a14502d90820',
    messagingSenderId: '446296947297',
    projectId: 'taskwhiz-11cbf',
    storageBucket: 'taskwhiz-11cbf.firebasestorage.app',
    iosBundleId: 'com.example.todoAi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAaFI5hutycONvzsb5TGJxYBvj_zymdoIw',
    appId: '1:446296947297:web:57bde056874bac6fd90820',
    messagingSenderId: '446296947297',
    projectId: 'taskwhiz-11cbf',
    authDomain: 'taskwhiz-11cbf.firebaseapp.com',
    storageBucket: 'taskwhiz-11cbf.firebasestorage.app',
    measurementId: 'G-E7QCK6GEX0',
  );
}