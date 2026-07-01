import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'data/database/database_helper.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    '[Background Message] ${message.notification?.title}',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (error) {
    debugPrint(
      'Environment variables loading failed: $error',
    );
  }

  // Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await AuthService().initializePersistence();

    FirebaseMessaging.onBackgroundMessage(
      _firebaseBackgroundHandler,
    );

    await NotificationService.instance.initialize();
  } catch (error) {
    debugPrint(
      'Firebase initialization failed: $error',
    );
  }

  // Database
  try {
    await DatabaseHelper.instance.ensureInitialized();

    SyncService.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint(
      'Database initialization failed: $error',
    );
    debugPrint('$stackTrace');
  }

  runApp(
    const ProviderScope(
      child: InventoryApp(),
    ),
  );
}