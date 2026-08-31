// File generated manually with values from the Firebase console
// (equivalent to running `flutterfire configure`).
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Usage:
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by registering a macOS app in the '
          'Firebase console and re-running this setup.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by registering a Windows app in the '
          'Firebase console and re-running this setup.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by registering a Linux app in the '
          'Firebase console and re-running this setup.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAld-yJjh-cZMzeoaCAuBGLsWXxa_9fLq4',
    appId: '1:736399794122:web:a74ec34c14e61e515e7933',
    messagingSenderId: '736399794122',
    projectId: 'piecrew-9fb0f',
    authDomain: 'piecrew-9fb0f.firebaseapp.com',
    storageBucket: 'piecrew-9fb0f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAld-yJjh-cZMzeoaCAuBGLsWXxa_9fLq4',
    appId: '1:736399794122:android:c5b41aa8d2134df15e7933',
    messagingSenderId: '736399794122',
    projectId: 'piecrew-9fb0f',
    storageBucket: 'piecrew-9fb0f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAld-yJjh-cZMzeoaCAuBGLsWXxa_9fLq4',
    appId: '1:736399794122:ios:5a8d9ca4485025075e7933',
    messagingSenderId: '736399794122',
    projectId: 'piecrew-9fb0f',
    storageBucket: 'piecrew-9fb0f.firebasestorage.app',
    iosBundleId: 'com.yourpie.piecrew',
  );
}
