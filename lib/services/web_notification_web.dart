// Real implementation — only compiled in when targeting web.
import 'dart:html' as html;

class WebNotificationHelper {
  static Future<void> requestPermission() async {
    try {
      final permission = await html.Notification.requestPermission();
      // ignore: avoid_print
      print('[HTML5 Notifications] permission: $permission');
    } catch (e) {
      // ignore: avoid_print
      print('[HTML5 Notifications] requestPermission error: $e');
    }
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    try {
      if (html.Notification.supported) {
        if (html.Notification.permission == 'granted') {
          html.Notification(title, body: body);
        } else {
          final permission = await html.Notification.requestPermission();
          if (permission == 'granted') {
            html.Notification(title, body: body);
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[HTML5 Notification] error: $e');
    }
  }

  static bool get isSupported => html.Notification.supported;
}