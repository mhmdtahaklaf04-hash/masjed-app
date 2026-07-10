import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// سرویس مدیریت Push Notification (FCM)
/// ارسال اعلان واقعی (به همه/گروهی/زمان‌بندی‌شده) باید از سمت سرور
/// یا Cloud Functions با استفاده از FCM Admin SDK انجام شود؛
/// این سرویس سمت کلاینت مسئول دریافت و ثبت توکن است.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyFcmToken, token);
    }

    // عضویت پیش‌فرض در topic «all_users» تا اعلان‌های عمومی ارسالی از سمت
    // سرور/Cloud Functions (برای گزینه «ارسال به همه کاربران» در پنل مدیریت)
    // به همه کاربران برسد.
    await subscribeToTopic('all_users');

    _messaging.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyFcmToken, newToken);
    });

    FirebaseMessaging.onMessage.listen((message) {
      // TODO: نمایش اعلان داخل اپ (local notification) هنگام باز بودن برنامه
    });
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}
