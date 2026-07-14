import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('========== BACKGROUND NOTIFICATION ==========');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
  debugPrint('=============================================');
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestNotificationPermission();

    final token = await getFcmToken();

    debugPrint('================ FCM TOKEN ================');
    debugPrint(token);
    debugPrint('===========================================');

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
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('============== NEW FCM TOKEN ==============');
      debugPrint(newToken);
      debugPrint('===========================================');

      // لاحقاً هنا نرسل التوكن الجديد إلى Laravel
      // مثلاً: AuthRepository.updateFcmToken(newToken)
    });
  }

  static void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('========== FOREGROUND NOTIFICATION ==========');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      debugPrint('=============================================');
    });
  }

  static void _listenToNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('========== NOTIFICATION CLICKED ==========');
      debugPrint('Data: ${message.data}');
      debugPrint('==========================================');
    });
  }
}
