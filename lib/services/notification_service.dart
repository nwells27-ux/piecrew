import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auth_service.dart';

/// Registers this device for push notifications and keeps the user's
/// FCM token in Firestore up to date. Actual push delivery (e.g. when
/// a manager posts an announcement) is handled by a Cloud Function
/// trigger — see /firebase/functions_notes.md for what to build there.
class NotificationService {
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final AuthService _authService;

  NotificationService(this._authService);

  Future<void> init(String uid) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final token = await _messaging.getToken();
    if (token != null) {
      await _authService.updateFcmToken(uid, token);
    }
    _messaging.onTokenRefresh.listen((t) => _authService.updateFcmToken(uid, t));

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'piecrew_general',
          'PieCrew Announcements & Chat',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
