// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // For Android, iOS, macOS → use native config (google-services.json)
    throw UnsupportedError(
      'FirebaseOptions are only required for web. Other platforms use google-services.json / GoogleService-Info.plist',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCXeozPv8cvS1IKp3KvIw7bm4hwBAAckOE",
    authDomain: "iiitnrplanner.firebaseapp.com",
    projectId: "iiitnrplanner",
    storageBucket: "iiitnrplanner.firebasestorage.app",
    messagingSenderId: "919070781012",
    appId: "1:919070781012:web:207e6c34c5a002c58207c1",
    measurementId: "G-LN4210H5LM",
  );
}
