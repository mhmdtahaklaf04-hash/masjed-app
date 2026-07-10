import 'package:flutter/material.dart';
import '../services/prayer_time_service.dart';

class PrayerTimeProvider extends ChangeNotifier {
  final PrayerTimeService _service = PrayerTimeService();

  PrayerTimesResult? _times;
  bool _isLoading = false;

  // مختصات پیش‌فرض (قابل تغییر بر اساس موقعیت واقعی کاربر / تنظیمات هیئت)
  double _latitude = 35.6892;
  double _longitude = 51.3890;

  PrayerTimesResult? get times => _times;
  bool get isLoading => _isLoading;

  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    _times = _service.calculate(latitude: _latitude, longitude: _longitude);
    _isLoading = false;
    notifyListeners();
  }
}
