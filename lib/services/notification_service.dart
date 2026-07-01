// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // Conditional import: uses the real dart:html implementation ONLY when
// // compiling for web. On Android/iOS it silently swaps in the no-op stub,
// // so dart:html never gets pulled into the mobile build at all.
// import 'web_notification_stub.dart'
//     if (dart.library.html) 'web_notification_web.dart';

// // ─── Background handler (must be top-level) ────────────────────────────────
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   debugPrint('[FCM Background] ${message.notification?.title}');
// }

// // ─── NotificationService ─────────────────────────────────────────────────────
// class NotificationService {
//   NotificationService._();

//   static final NotificationService instance = NotificationService._();

//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;

//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();

//   bool _initialized = false;

//   static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
//     'inventory_channel',
//     'Inventory Alerts',
//     description: 'Notifications for low-stock and inventory events',
//     importance: Importance.high,
//   );

//   // ── Public entry-point ────────────────────────────────────────────────────
//   Future<void> initialize() async {
//     if (_initialized) return;

//     try {
//       if (kIsWeb) {
//         await _initializeWeb();
//       } else {
//         await _initializeMobile();
//       }
//       _initialized = true;
//     } catch (e) {
//       debugPrint('[NotificationService] initialize error: $e');
//     }
//   }

//   // ── Mobile (Android + iOS) ────────────────────────────────────────────────
//   Future<void> _initializeMobile() async {
//     // 1. Request FCM / system permission (important for Android 13+ and iOS).
//     final settings = await _fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     debugPrint('[FCM Permission] ${settings.authorizationStatus}');

//     // 2. Initialize flutter_local_notifications.
//     const initSettings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//       iOS: DarwinInitializationSettings(),
//     );

//     await _localNotifications.initialize(
//   settings: initSettings,
//   onDidReceiveNotificationResponse: (response) {
//     debugPrint('Notification clicked: ${response.payload}');
//   },
// );

//     // 3. Create the Android notification channel.
//     await _localNotifications
//     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//     ?.createNotificationChannel(_channel);
//     // 4. Wire up FCM listeners.
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     FirebaseMessaging.onMessage.listen((message) {
//       final n = message.notification;
//       if (n != null) {
//         showLocalNotification(
//           title: n.title ?? 'Inventory Alert',
//           body: n.body ?? '',
//         );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       debugPrint('[FCM Opened] data: ${message.data}');
//     });

//     // 5. Log the device token for server-side use (send this to your backend).
//     final token = await _fcm.getToken();
//     debugPrint('[FCM Token] $token');
//   }

//   // ── Web ───────────────────────────────────────────────────────────────────
//   Future<void> _initializeWeb() async {
//     try {
//       final token = await _fcm.getToken(
//         vapidKey: 'YOUR_WEB_PUSH_CERTIFICATE_KEY',
//       );
//       debugPrint('[FCM Web Token] $token');

//       FirebaseMessaging.onMessage.listen((message) {
//         final n = message.notification;
//         if (n != null) {
//           showLocalNotification(
//             title: n.title ?? 'Inventory Alert',
//             body: n.body ?? '',
//           );
//         }
//       });
//     } catch (e) {
//       debugPrint('[FCM Web] token error ($e) – falling back to HTML5');
//     }

//     await WebNotificationHelper.requestPermission();
//   }

//   // ── Public: show a notification ───────────────────────────────────────────
//   Future<void> showLocalNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     if (kIsWeb) {
//       await WebNotificationHelper.show(title: title, body: body);
//       return;
//     }

//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'inventory_channel',
//         'Inventory Alerts',
//         channelDescription:
//             'Notifications for low-stock and inventory events',
//         importance: Importance.max,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//       ),
//       iOS: DarwinNotificationDetails(),
//     );

//     await _localNotifications.show(
//   id: DateTime.now().microsecondsSinceEpoch % 100000,
//   title: title,
//   body: body,
//   notificationDetails: details,
//   payload: payload,
// );
//   }

//   // ── Helpers ────────────────────────────────────────────────────────────────
//   Future<String?> getToken() async {
//     if (kIsWeb) {
//       return _fcm.getToken(vapidKey: 'YOUR_WEB_PUSH_CERTIFICATE_KEY');
//     }
//     return _fcm.getToken();
//   }

//   Future<void> subscribeToTopic(String topic) async {
//     if (!kIsWeb) {
//       await _fcm.subscribeToTopic(topic);
//       debugPrint('[FCM] subscribed to $topic');
//     }
//   }

//   Future<void> unsubscribeFromTopic(String topic) async {
//     if (!kIsWeb) {
//       await _fcm.unsubscribeFromTopic(topic);
//       debugPrint('[FCM] unsubscribed from $topic');
//     }
//   }
// }
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Conditional import — real dart:html implementation only on web;
// no-op stub on Android/iOS, so dart:html never enters the mobile build.
import 'web_notification_stub.dart'
    if (dart.library.html) 'web_notification_web.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] ${message.notification?.title}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'inventory_channel',
    'Inventory Alerts',
    description: 'Notifications for low-stock and inventory events',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        await _initializeWeb();
      } else {
        await _initializeMobile();
      }
      _initialized = true;
    } catch (e) {
      debugPrint('[NotificationService] initialize error: $e');
    }
  }

  Future<void> _initializeMobile() async {
    // 1. Request FCM / system permission (Android 13+ needs POST_NOTIFICATIONS).
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM Permission] ${settings.authorizationStatus}');

    // 2. Initialize flutter_local_notifications.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // 3. Create the Android notification channel + request runtime permission.
   final androidImpl = _localNotifications
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

await androidImpl?.createNotificationChannel(_channel);
await androidImpl?.requestNotificationsPermission();
    // 4. Wire up FCM listeners.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n != null) {
        showLocalNotification(
          title: n.title ?? 'Inventory Alert',
          body: n.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM Opened] data: ${message.data}');
    });

    // 5. Log the device token — send this to your backend to target this device.
    final token = await _fcm.getToken();
    debugPrint('[FCM Token] $token');
  }

  Future<void> _initializeWeb() async {
    try {
      final token = await _fcm.getToken(
        vapidKey: 'YOUR_WEB_PUSH_CERTIFICATE_KEY',
      );
      debugPrint('[FCM Web Token] $token');

      FirebaseMessaging.onMessage.listen((message) {
        final n = message.notification;
        if (n != null) {
          showLocalNotification(
            title: n.title ?? 'Inventory Alert',
            body: n.body ?? '',
          );
        }
      });
    } catch (e) {
      debugPrint('[FCM Web] token error ($e) – falling back to HTML5');
    }

    await WebNotificationHelper.requestPermission();
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      await WebNotificationHelper.show(title: title, body: body);
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'inventory_channel',
        'Inventory Alerts',
        channelDescription:
            'Notifications for low-stock and inventory events',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      id: DateTime.now().microsecondsSinceEpoch % 100000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      return _fcm.getToken(vapidKey: 'YOUR_WEB_PUSH_CERTIFICATE_KEY');
    }
    return _fcm.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    if (!kIsWeb) {
      await _fcm.subscribeToTopic(topic);
      debugPrint('[FCM] subscribed to $topic');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (!kIsWeb) {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('[FCM] unsubscribed from $topic');
    }
  }
}