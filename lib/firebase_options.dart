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
    apiKey: 'AIzaSyDHPOJoLCOYCXJZnCnwjdoqt83UwZElsZ0',
    appId: '1:1034035244293:web:9a9a2cfd159011e47edb6c',
    messagingSenderId: '1034035244293',
    projectId: 'pokedexflutter-3d266',
    authDomain: 'pokedexflutter-3d266.firebaseapp.com',
    storageBucket: 'pokedexflutter-3d266.appspot.com',
    measurementId: 'G-23L8M2C3GM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmWrTO948jn757LMzmLMItIu4WhrC8vZ0',
    appId: '1:1034035244293:android:d94943497cb4e4d07edb6c',
    messagingSenderId: '1034035244293',
    projectId: 'pokedexflutter-3d266',
    storageBucket: 'pokedexflutter-3d266.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBi_McdYzRHjAkazKP-culTahrgTkDuahg',
    appId: '1:1034035244293:ios:bff057bf010081f17edb6c',
    messagingSenderId: '1034035244293',
    projectId: 'pokedexflutter-3d266',
    storageBucket: 'pokedexflutter-3d266.appspot.com',
    iosBundleId: 'com.example.pokedexapp',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBi_McdYzRHjAkazKP-culTahrgTkDuahg',
    appId: '1:1034035244293:ios:bff057bf010081f17edb6c',
    messagingSenderId: '1034035244293',
    projectId: 'pokedexflutter-3d266',
    storageBucket: 'pokedexflutter-3d266.appspot.com',
    iosBundleId: 'com.example.pokedexapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDHPOJoLCOYCXJZnCnwjdoqt83UwZElsZ0',
    appId: '1:1034035244293:web:e98525a49ec897ba7edb6c',
    messagingSenderId: '1034035244293',
    projectId: 'pokedexflutter-3d266',
    authDomain: 'pokedexflutter-3d266.firebaseapp.com',
    storageBucket: 'pokedexflutter-3d266.appspot.com',
    measurementId: 'G-SSZ1GLH1ED',
  );

}