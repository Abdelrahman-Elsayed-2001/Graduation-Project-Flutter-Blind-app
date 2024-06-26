// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyASoyGvoP4e-NOA9UeykWtMaKSByVvSxDA',
    appId: '1:123695465211:web:f720225d72787fcb8a665e',
    messagingSenderId: '123695465211',
    projectId: 'chat-project-5a0b8',
    authDomain: 'chat-project-5a0b8.firebaseapp.com',
    databaseURL: 'https://chat-project-5a0b8-default-rtdb.firebaseio.com',
    storageBucket: 'chat-project-5a0b8.appspot.com',
    measurementId: 'G-L0P0VYNX15',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6wIbckG4qu5m0AFTHJyjdGHhoVv2fS8g',
    appId: '1:123695465211:android:ce359eb33be5ce878a665e',
    messagingSenderId: '123695465211',
    projectId: 'chat-project-5a0b8',
    databaseURL: 'https://chat-project-5a0b8-default-rtdb.firebaseio.com',
    storageBucket: 'chat-project-5a0b8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYOfulSj_ncTBbKgNCdFT54F0uRGkUvbM',
    appId: '1:123695465211:ios:823c21ede7cbd0428a665e',
    messagingSenderId: '123695465211',
    projectId: 'chat-project-5a0b8',
    databaseURL: 'https://chat-project-5a0b8-default-rtdb.firebaseio.com',
    storageBucket: 'chat-project-5a0b8.appspot.com',
    androidClientId: '123695465211-c4kq3iscg979qb7b83nvgghpktrnal59.apps.googleusercontent.com',
    iosClientId: '123695465211-tcriug5gipc3g06rl84i051q8k21h0kl.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatgptCourse',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYOfulSj_ncTBbKgNCdFT54F0uRGkUvbM',
    appId: '1:123695465211:ios:823c21ede7cbd0428a665e',
    messagingSenderId: '123695465211',
    projectId: 'chat-project-5a0b8',
    databaseURL: 'https://chat-project-5a0b8-default-rtdb.firebaseio.com',
    storageBucket: 'chat-project-5a0b8.appspot.com',
    androidClientId: '123695465211-c4kq3iscg979qb7b83nvgghpktrnal59.apps.googleusercontent.com',
    iosClientId: '123695465211-tcriug5gipc3g06rl84i051q8k21h0kl.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatgptCourse',
  );
}
