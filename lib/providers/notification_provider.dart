import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isSending = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  /// فقط اعلان‌هایی که زمان‌بندی‌شان رسیده (یا اصلاً زمان‌بندی نداشته‌اند)
  List<NotificationModel> get visibleNotifications =>
      _notifications.where((n) => !n.isScheduled).toList();

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _service.streamCollection(
        AppConstants.notificationsCollection,
      ).first;
      _notifications =
          snap.docs.map((d) => NotificationModel.fromMap(d.id, d.data())).toList();
    } catch (_) {
      _notifications = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// ثبت اعلان جدید. توجه: ارسال Push واقعی (نمایش نوتیفیکیشن سیستمی به‌محض
  /// ارسال) نیازمند Cloud Functions یا سرور با FCM Admin SDK است؛ این متد
  /// اعلان را در Firestore ثبت می‌کند تا در صفحه «اعلان‌ها»ی کاربران نمایش
  /// داده شود و برای ارسال Push از طریق سرور نیز قابل استفاده باشد.
  Future<bool> send(NotificationModel notification) async {
    _isSending = true;
    notifyListeners();
    try {
      await _service.create(
        AppConstants.notificationsCollection,
        notification.toMap(),
      );
      _isSending = false;
      notifyListeners();
      await fetchAll();
      return true;
    } catch (e) {
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> delete(String id) async {
    await _service.delete(AppConstants.notificationsCollection, id);
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
