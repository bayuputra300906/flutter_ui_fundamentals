import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_keys.dart';
import '../firebase_options.dart';
import '../pages/kos_detail_page.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[BACKGROUND] ${message.notification?.title}');
    debugPrint('[BACKGROUND] ${message.notification?.body}');
  } catch (_) {}
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<AuthorizationStatus> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('Notification permission: ${settings.authorizationStatus.name}');
      return settings.authorizationStatus;
    } catch (e) {
      debugPrint('Notification permission notice: $e');
      return AuthorizationStatus.authorized;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('FCM Token notice (Web/Dev mode): $e');
      return 'fcm_token_dev_sample_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void listenTokenRefresh(void Function(String token) onRefresh) {
    try {
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token diperbarui');
        onRefresh(newToken);
      });
    } catch (_) {}
  }

  Future<void> saveTokenToSupabase(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('device_tokens').upsert({
        'token': token,
        'user_id': user.id,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> init() async {
    try {
      await requestPermission();

      final token = await getToken();
      if (token != null) await saveTokenToSupabase(token);
      listenTokenRefresh(saveTokenToSupabase);

      // iOS presentation options
      try {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (_) {}

      // FOREGROUND listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FOREGROUND] Notification received');
        final title = message.notification?.title ?? 'Notifikasi';
        final body = message.notification?.body ?? '';
        messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('$title\n$body')),
        );
      });
    } catch (e) {
      debugPrint('NotificationService init completed with fallback: $e');
    }
  }

  Future<void> setupInteractedMessage() async {
    try {
      final initial = await _messaging.getInitialMessage();
      if (initial != null) _handleTap(initial);

      FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    } catch (_) {}
  }

  void _handleTap(RemoteMessage message) {
    final kosId = message.data['kos_id'];
    if (kosId == null) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => KosDetailPage(kosId: kosId.toString()),
      ),
    );
  }
}
