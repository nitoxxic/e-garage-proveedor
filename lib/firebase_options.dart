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
    apiKey: 'AIzaSyDQ_6u--52No7rIQAjP2OhZfPhEEA7xKKw',
    appId: '1:148220246207:web:aeb02ccece97bf9827ae0a',
    messagingSenderId: '148220246207',
    projectId: 'db-e-garage-voratium',
    authDomain: 'db-e-garage-voratium.firebaseapp.com',
    storageBucket: 'db-e-garage-voratium.appspot.com',
    measurementId: 'G-RM3RWYWJP1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_KTSxSvGKpZnKxqdnM4Hdd8jnErbCPqM',
    appId: '1:148220246207:android:64036e97dd72896127ae0a',
    messagingSenderId: '148220246207',
    projectId: 'db-e-garage-voratium',
    storageBucket: 'db-e-garage-voratium.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAh76HhRrpSrBnQECtZFoRSUxlCO8GouhY',
    appId: '1:148220246207:ios:8c4d72de268a4b0627ae0a',
    messagingSenderId: '148220246207',
    projectId: 'db-e-garage-voratium',
    storageBucket: 'db-e-garage-voratium.appspot.com',
    iosBundleId: 'com.example.eGarage',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAh76HhRrpSrBnQECtZFoRSUxlCO8GouhY',
    appId: '1:148220246207:ios:8c4d72de268a4b0627ae0a',
    messagingSenderId: '148220246207',
    projectId: 'db-e-garage-voratium',
    storageBucket: 'db-e-garage-voratium.appspot.com',
    iosBundleId: 'com.example.eGarage',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQ_6u--52No7rIQAjP2OhZfPhEEA7xKKw',
    appId: '1:148220246207:web:605b04052606c4b227ae0a',
    messagingSenderId: '148220246207',
    projectId: 'db-e-garage-voratium',
    authDomain: 'db-e-garage-voratium.firebaseapp.com',
    storageBucket: 'db-e-garage-voratium.appspot.com',
    measurementId: 'G-3K9NE3RYY4',
  );
}
