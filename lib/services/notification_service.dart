import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  debugPrint(
    '[FCM Background] ${message.notification?.title}',
  );
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FirebaseMessaging _fcm =
      FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin
      _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'inventory_channel',
    'Inventory Alerts',
    description: 'Inventory notifications',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (!kIsWeb) {
        await _initializeAndroid();
      } else {
        await _initializeWeb();
      }

      _initialized = true;
    } catch (e) {
      debugPrint(
        '[NotificationService] $e',
      );
    }
  }

  Future<void> _initializeAndroid() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      '[Permission] ${settings.authorizationStatus}',
    );

    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings =
        DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
  settings: initSettings,
  onDidReceiveNotificationResponse: (response) {
    debugPrint(
      '[NotificationService] Notification clicked',
    );
  },
);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          _channel,
        );

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    FirebaseMessaging.onMessage.listen(
      (message) {
        if (message.notification != null) {
          showLocalNotification(
            title:
                message.notification!.title ??
                'Notification',
            body:
                message.notification!.body ??
                '',
          );
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        debugPrint(
          '[Opened] ${message.data}',
        );
      },
    );

    final token = await _fcm.getToken();

    debugPrint(
      '[FCM TOKEN] $token',
    );
  }

  Future<void> _initializeWeb() async {
    try {
      final token =
          await _fcm.getToken(
        vapidKey:
            'YOUR_WEB_PUSH_CERTIFICATE_KEY',
      );

      debugPrint(
        '[WEB TOKEN] $token',
      );
    } catch (e) {
      debugPrint(
        '[WEB] $e',
      );
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      debugPrint(
        '[WEB] $title : $body',
      );
      return;
    }

    const androidDetails =
        AndroidNotificationDetails(
      'inventory_channel',
      'Inventory Alerts',
      channelDescription:
          'Inventory notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails =
        DarwinNotificationDetails();

    const details =
        NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
  id: DateTime.now().millisecond,
  title: title,
  body: body,
  notificationDetails: details,
  payload: payload,
);
  }
}