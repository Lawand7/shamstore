import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage _) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background notification received.');
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestNotificationPermission();

    await getFcmToken();

    _listenToTokenRefresh();
    _listenToForegroundMessages();
    _listenToNotificationClicks();
  }

  static Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }

  static Future<void> _requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  static void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((_) {
      debugPrint('FCM token refreshed.');

      // لاحقاً هنا نرسل التوكن الجديد إلى Laravel
      // مثلاً: AuthRepository.updateFcmToken(newToken)
    });
  }

  static void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((_) {
      debugPrint('Foreground notification received.');
    });
  }

  static void _listenToNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      debugPrint('Notification opened.');
    });
  }
}
