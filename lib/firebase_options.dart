import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
    apiKey: 'AIzaSyCy8x7LnVWwbNoAoeCqOkZzkOGJ5_J8gns',
    appId: '1:226279795549:web:07aab1825d5d5712ac16b4',
    messagingSenderId: '226279795549',
    projectId: 'sawaari-d6e13',
    authDomain: 'sawaari-d6e13.firebaseapp.com',
    storageBucket: 'sawaari-d6e13.firebasestorage.app',
    measurementId: 'G-2R44RSVYLZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlwpJ4uvYF5ayNW4RO-kng4oQzeVSSkC4',
    appId: '1:226279795549:android:9b13742502a190edac16b4',
    messagingSenderId: '226279795549',
    projectId: 'sawaari-d6e13',
    storageBucket: 'sawaari-d6e13.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACAVg5rinFdRd1Ia-qoGavVl2aGX6fSH8',
    appId: '1:226279795549:ios:0f6a27f5a79d8247ac16b4',
    messagingSenderId: '226279795549',
    projectId: 'sawaari-d6e13',
    storageBucket: 'sawaari-d6e13.firebasestorage.app',
    iosBundleId: 'com.basoft.customer.ba.comBasoftCustomerBa',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyACAVg5rinFdRd1Ia-qoGavVl2aGX6fSH8',
    appId: '1:226279795549:ios:0f6a27f5a79d8247ac16b4',
    messagingSenderId: '226279795549',
    projectId: 'sawaari-d6e13',
    storageBucket: 'sawaari-d6e13.firebasestorage.app',
    iosBundleId: 'com.basoft.customer.ba.comBasoftCustomerBa',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCy8x7LnVWwbNoAoeCqOkZzkOGJ5_J8gns',
    appId: '1:226279795549:web:01267c94b359ffceac16b4',
    messagingSenderId: '226279795549',
    projectId: 'sawaari-d6e13',
    authDomain: 'sawaari-d6e13.firebaseapp.com',
    storageBucket: 'sawaari-d6e13.firebasestorage.app',
    measurementId: 'G-HJBPPXQER5',
  );
}
