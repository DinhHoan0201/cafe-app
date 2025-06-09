import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCefxuncKstW06MJ24NHd5yS9q0D4A0eA0',
    appId: '1:500664071155:web:07c074f951b0f7ad841886',
    messagingSenderId: '500664071155',
    projectId: 'cfdb-17821',
    authDomain: 'cfdb-17821.firebaseapp.com',
    storageBucket: 'cfdb-17821.firebasestorage.app',
    measurementId: 'G-S9CYP19897',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTNGL8KeyrTXBAMQDAz-ejvDDfCiu4cRI',
    appId: '1:500664071155:android:4a696ed6e83e67ea841886',
    messagingSenderId: '500664071155',
    projectId: 'cfdb-17821',
    storageBucket: 'cfdb-17821.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADoCkULlfajwpYpqgIN9CUAU2f4hse8hM',
    appId: '1:500664071155:ios:caa8f57ae6055cca841886',
    messagingSenderId: '500664071155',
    projectId: 'cfdb-17821',
    storageBucket: 'cfdb-17821.firebasestorage.app',
    iosBundleId: 'com.example.myapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADoCkULlfajwpYpqgIN9CUAU2f4hse8hM',
    appId: '1:500664071155:ios:caa8f57ae6055cca841886',
    messagingSenderId: '500664071155',
    projectId: 'cfdb-17821',
    storageBucket: 'cfdb-17821.firebasestorage.app',
    iosBundleId: 'com.example.myapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCefxuncKstW06MJ24NHd5yS9q0D4A0eA0',
    appId: '1:500664071155:web:4415d3bbba56b085841886',
    messagingSenderId: '500664071155',
    projectId: 'cfdb-17821',
    authDomain: 'cfdb-17821.firebaseapp.com',
    storageBucket: 'cfdb-17821.firebasestorage.app',
    measurementId: 'G-BTMHEH0JMW',
  );
}
