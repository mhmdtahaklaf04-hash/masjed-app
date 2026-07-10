// این فایل باید با اجرای دستور زیر به‌صورت خودکار تولید شود:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// دستور بالا با اتصال به پروژه Firebase شما (که باید در console.firebase.google.com
// بسازید) این فایل را با کلیدهای واقعی API جایگزین می‌کند.
// فایل زیر فقط یک نمونه/Placeholder برای کامپایل شدن پروژه است.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions در این پلتفرم پیکربندی نشده است. '
          'دستور flutterfire configure را اجرا کنید.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'cheragh-app',
    storageBucket: 'cheragh-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'cheragh-app',
    storageBucket: 'cheragh-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'cheragh-app',
    storageBucket: 'cheragh-app.appspot.com',
    iosBundleId: 'ir.cheragh.heyat',
  );
}
