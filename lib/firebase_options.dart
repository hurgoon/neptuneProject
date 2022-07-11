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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_TEDMmLykop5LEHMTDTxv89A7YtOjyhw',
    appId: '1:11475866906:android:60dd8313096c282866c8a3',
    messagingSenderId: '11475866906',
    projectId: 'neptuneproject-e13d0',
    storageBucket: 'neptuneproject-e13d0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJveHPTSm_0_cXjZKpReKusWByQ3Qpppg',
    appId: '1:11475866906:ios:b5952c32cc05f2d866c8a3',
    messagingSenderId: '11475866906',
    projectId: 'neptuneproject-e13d0',
    storageBucket: 'neptuneproject-e13d0.appspot.com',
    androidClientId: '11475866906-v0faf71h2u64c7dk910eg1k5b053qmb6.apps.googleusercontent.com',
    iosClientId: '11475866906-ndke9npnkc3qrns648rp6aqpsntah20p.apps.googleusercontent.com',
    iosBundleId: 'com.example.neptuneProject',
  );
}
