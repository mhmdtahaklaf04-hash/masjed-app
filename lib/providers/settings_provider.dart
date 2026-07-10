import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/color_utils.dart';
import '../models/settings_model.dart';
import '../services/firestore_service.dart';

/// مدیریت تنظیمات سراسری برنامه (شماره کارت، اطلاعات تماس، لوگو، رنگ‌ها)
/// که در پنل مدیریت قابل تغییر است و همه کاربران آن را می‌بینند.
class SettingsProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  SettingsModel _settings = const SettingsModel();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _loaded = false;

  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Color? get primaryColor => ColorUtils.fromHex(_settings.primaryColorHex);
  Color? get secondaryColor => ColorUtils.fromHex(_settings.secondaryColorHex);

  Future<void> fetch({bool force = false}) async {
    if (_loaded && !force) return;
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await _service.getById(
        AppConstants.settingsCollection,
        AppConstants.settingsDocId,
      );
      if (doc.exists && doc.data() != null) {
        _settings = SettingsModel.fromMap(doc.data()!);
      }
      _loaded = true;
    } catch (_) {
      // در صورت خطا (مثلاً عدم دسترسی به شبکه)، مقادیر پیش‌فرض حفظ می‌شود
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> save(SettingsModel newSettings) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _service.createWithId(
        AppConstants.settingsCollection,
        AppConstants.settingsDocId,
        newSettings.toMap(),
      );
      _settings = newSettings;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
