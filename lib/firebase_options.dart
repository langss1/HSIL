import 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase configuration — HSIL Attendance Project
/// Project ID  : hsil-attendance
/// Project No. : 863084950012
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS     => ios,
      TargetPlatform.macOS   => macos,
      TargetPlatform.windows => web,   // web config for windows runner
      TargetPlatform.linux   => android,
      TargetPlatform.fuchsia => android,
    };
  }

  // ── Android ─────────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyBrwAY1h7cP0fRSonVC113xAlvB8Otf8sE',
    appId:             '1:863084950012:android:bf3881bad6243878d90279',
    messagingSenderId: '863084950012',
    projectId:         'hsil-attendance',
    storageBucket:     'hsil-attendance.firebasestorage.app',
  );

  // ── Web / Windows placeholder (update setelah tambah Web app di Console) ───
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyBrwAY1h7cP0fRSonVC113xAlvB8Otf8sE',
    appId:             '1:863084950012:web:0000000000000000000000',
    messagingSenderId: '863084950012',
    projectId:         'hsil-attendance',
    authDomain:        'hsil-attendance.firebaseapp.com',
    storageBucket:     'hsil-attendance.firebasestorage.app',
    measurementId:     'G-0000000000',
  );

  // ── iOS placeholder (update jika perlu build iOS) ────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'AIzaSyBrwAY1h7cP0fRSonVC113xAlvB8Otf8sE',
    appId:             '1:863084950012:ios:0000000000000000000000',
    messagingSenderId: '863084950012',
    projectId:         'hsil-attendance',
    storageBucket:     'hsil-attendance.firebasestorage.app',
    iosBundleId:       'com.langss.hsil.hsilAttendance',
  );

  static const FirebaseOptions macos = ios;
}
