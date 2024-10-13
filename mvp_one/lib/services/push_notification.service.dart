import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    // Handle notifications when the app is re-launched after being terminated
    FirebaseMessaging.instance.getInitialMessage().then((value) => null);

    // Handle the scenario when the app is closed or running in the background,
    // and the user clicks on a notification to open the app.
    FirebaseMessaging.onMessageOpenedApp.listen(_messageOpenedAppHandler);

    // Handle notifications when the app is in the background or terminated, and a new FCM message arrives
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle notifications when the app is in the foreground, and a new FCM message arrives
    FirebaseMessaging.onMessage.listen(_messageHandler);
  }

  static Future<void> _messageOpenedAppHandler(RemoteMessage message) async {}

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {}

  static Future<void> _messageHandler(RemoteMessage message) async {}
}
