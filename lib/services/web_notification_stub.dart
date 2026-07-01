// Stub used on Android/iOS — never touches dart:html.
class WebNotificationHelper {
  static Future<void> requestPermission() async {}

  static Future<void> show({
    required String title,
    required String body,
  }) async {}

  static bool get isSupported => false;
}