// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps, configured dynamically via environment variables.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final apiKey = dotenv.env['FIREBASE_API_KEY'];
    final appId = dotenv.env['FIREBASE_APP_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'];

    // Provide default fallbacks if they are empty/null to avoid crash during init but print warning
    return FirebaseOptions(
      apiKey: apiKey ?? 'placeholder_key',
      appId: appId ?? 'placeholder_app_id',
      messagingSenderId: messagingSenderId ?? 'placeholder_sender_id',
      projectId: projectId ?? 'placeholder_project_id',
      authDomain: '${projectId ?? "placeholder_project_id"}.firebaseapp.com',
      storageBucket: '${projectId ?? "placeholder_project_id"}.firebasestorage.app',
    );
  }
}
