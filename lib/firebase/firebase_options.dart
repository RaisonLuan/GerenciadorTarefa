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
    apiKey: 'AIzaSyAVSEloqtaPiIrGeZwW-fyHzsqg5wz5B38',
    appId: '1:174176186593:web:f99cce57da077c228bc7a0',
    messagingSenderId: '174176186593',
    projectId: 'projeto-farmacia-rlf',
    authDomain: 'projeto-farmacia-rlf.firebaseapp.com',
    databaseURL: 'https://projeto-farmacia-rlf-default-rtdb.firebaseio.com',
    storageBucket: 'projeto-farmacia-rlf.appspot.com',
    measurementId: 'G-CY05VLGNFR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDujBHFbDeHENIust8IC0ULE_VKF40fbfo',
    appId: '1:174176186593:android:1946a3761bf43c3d8bc7a0',
    messagingSenderId: '174176186593',
    projectId: 'projeto-farmacia-rlf',
    databaseURL: 'https://projeto-farmacia-rlf-default-rtdb.firebaseio.com',
    storageBucket: 'projeto-farmacia-rlf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCAMHFXakAXBNHg26owh6sOhd2nHe3BVKY',
    appId: '1:174176186593:ios:0475c20b1360f4328bc7a0',
    messagingSenderId: '174176186593',
    projectId: 'projeto-farmacia-rlf',
    databaseURL: 'https://projeto-farmacia-rlf-default-rtdb.firebaseio.com',
    storageBucket: 'projeto-farmacia-rlf.appspot.com',
    iosBundleId: 'com.example.ex',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCAMHFXakAXBNHg26owh6sOhd2nHe3BVKY',
    appId: '1:174176186593:ios:0475c20b1360f4328bc7a0',
    messagingSenderId: '174176186593',
    projectId: 'projeto-farmacia-rlf',
    databaseURL: 'https://projeto-farmacia-rlf-default-rtdb.firebaseio.com',
    storageBucket: 'projeto-farmacia-rlf.appspot.com',
    iosBundleId: 'com.example.ex',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAVSEloqtaPiIrGeZwW-fyHzsqg5wz5B38',
    appId: '1:174176186593:web:d15b430bf8a7cbb38bc7a0',
    messagingSenderId: '174176186593',
    projectId: 'projeto-farmacia-rlf',
    authDomain: 'projeto-farmacia-rlf.firebaseapp.com',
    databaseURL: 'https://projeto-farmacia-rlf-default-rtdb.firebaseio.com',
    storageBucket: 'projeto-farmacia-rlf.appspot.com',
    measurementId: 'G-SMRXEQ0EVQ',
  );
}
