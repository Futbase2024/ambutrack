// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';

// /// Configuración de Firebase para diferentes plataformas y flavors
// class DefaultFirebaseOptions {
//   static FirebaseOptions get currentPlatform {
//     if (kIsWeb) {
//       return web;
//     }
//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return android;
//       case TargetPlatform.iOS:
//         return ios;
//       case TargetPlatform.macOS:
//         return macos;
//       case TargetPlatform.windows:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for windows - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       case TargetPlatform.linux:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for linux - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       default:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions are not supported for this platform.',
//         );
//     }
//   }

//   static const FirebaseOptions web = FirebaseOptions(
//     apiKey: 'AIzaSyAj7ZbpUe7vbfiQJ3SdK2F8eF0WNKp9aXs',
//     appId: '1:478138120854:web:c3fb07790213bf6816e0b7',
//     messagingSenderId: '478138120854',
//     projectId: 'ambutrack-c2125',
//     authDomain: 'ambutrack-c2125.firebaseapp.com',
//     storageBucket: 'ambutrack-c2125.firebasestorage.app',
//     measurementId: 'G-GVPV7XS9X4',
//   );

//   /// Configuración para Web

//   /// Configuración para Android
//   static const FirebaseOptions android = FirebaseOptions(
//     apiKey: 'AIzaSyDemoKeyForAmbuTrackAndroid',
//     appId: '1:123456789:android:abcdef123456',
//     messagingSenderId: '123456789',
//     projectId: 'ambutrack-dev',
//     storageBucket: 'ambutrack-dev.appspot.com',
//   );

//   /// Configuración para iOS
//   static const FirebaseOptions ios = FirebaseOptions(
//     apiKey: 'AIzaSyDemoKeyForAmbuTrackiOS',
//     appId: '1:123456789:ios:abcdef123456',
//     messagingSenderId: '123456789',
//     projectId: 'ambutrack-dev',
//     storageBucket: 'ambutrack-dev.appspot.com',
//     iosBundleId: 'com.ambutrack.dev',
//   );

//   /// Configuración para macOS
//   static const FirebaseOptions macos = FirebaseOptions(
//     apiKey: 'AIzaSyDemoKeyForAmbuTrackmacOS',
//     appId: '1:123456789:ios:abcdef123456',
//     messagingSenderId: '123456789',
//     projectId: 'ambutrack-dev',
//     storageBucket: 'ambutrack-dev.appspot.com',
//     iosBundleId: 'com.ambutrack.dev',
//   );
// }