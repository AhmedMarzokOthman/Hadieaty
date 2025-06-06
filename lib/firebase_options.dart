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
    apiKey: 'AIzaSyCOj_jVduItn6ulpUrbeiMP73x0kqOYBCk',
    appId: '1:784150802180:web:ebd36977bb8adea70e6a51',
    messagingSenderId: '784150802180',
    projectId: 'flutter-hadieaty-project',
    authDomain: 'flutter-hadieaty-project.firebaseapp.com',
    storageBucket: 'flutter-hadieaty-project.firebasestorage.app',
    measurementId: 'G-Z049SV6MFT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB599tG4TARmK5XX0qKuIH4RvaJJL6uF50',
    appId: '1:784150802180:android:fe211039a78726d30e6a51',
    messagingSenderId: '784150802180',
    projectId: 'flutter-hadieaty-project',
    storageBucket: 'flutter-hadieaty-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqPxVOhTu2eZff2nzkph-vMn4-8AqNdko',
    appId: '1:784150802180:ios:5879f24bd93f7a060e6a51',
    messagingSenderId: '784150802180',
    projectId: 'flutter-hadieaty-project',
    storageBucket: 'flutter-hadieaty-project.firebasestorage.app',
    iosBundleId: 'com.example.hadieaty',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqPxVOhTu2eZff2nzkph-vMn4-8AqNdko',
    appId: '1:784150802180:ios:5879f24bd93f7a060e6a51',
    messagingSenderId: '784150802180',
    projectId: 'flutter-hadieaty-project',
    storageBucket: 'flutter-hadieaty-project.firebasestorage.app',
    iosBundleId: 'com.example.hadieaty',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCOj_jVduItn6ulpUrbeiMP73x0kqOYBCk',
    appId: '1:784150802180:web:83595eaab67f6f9e0e6a51',
    messagingSenderId: '784150802180',
    projectId: 'flutter-hadieaty-project',
    authDomain: 'flutter-hadieaty-project.firebaseapp.com',
    storageBucket: 'flutter-hadieaty-project.firebasestorage.app',
    measurementId: 'G-03E9P9N9L0',
  );

}