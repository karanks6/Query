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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArv--PHbNIyx7UmyLhcfuDXnds4SAsihA',
    appId: '1:489911977867:ios:42b8f63547d30d03ce518e',
    messagingSenderId: '489911977867',
    projectId: 'query-sql-game',
    storageBucket: 'query-sql-game.firebasestorage.app',
    iosBundleId: 'com.querybureau.query',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAvdWbbHI0vWRKWzkIyQUy3awZoInhuRVI',
    appId: '1:489911977867:android:1ee7ffba8fb0ace4ce518e',
    messagingSenderId: '489911977867',
    projectId: 'query-sql-game',
    storageBucket: 'query-sql-game.firebasestorage.app',
  );
}
