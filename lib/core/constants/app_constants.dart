class AppConstants {
  AppConstants._();

  static const String appName = 'چراغ';
  static const String appSubtitle = 'هیئت بابالحوائج زمان‌آباد';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String announcementsCollection = 'announcements';
  static const String eventsCollection = 'events';
  static const String audiosCollection = 'audios';
  static const String paymentsCollection = 'payments';
  static const String notificationsCollection = 'notifications';
  static const String settingsCollection = 'settings';
  static const String galleryCollection = 'gallery';
  static const String adminsCollection = 'admins';

  // شناسه سند واحد تنظیمات سراسری در collection «settings»
  static const String settingsDocId = 'app_config';

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserRole = 'user_role';
  static const String keyFcmToken = 'fcm_token';

  // Storage paths
  static const String storageAnnouncements = 'announcements';
  static const String storageAudios = 'audios';
  static const String storageGallery = 'gallery';
  static const String storageReceipts = 'receipts';
  static const String storageLogo = 'app_config';

  // Pagination
  static const int pageSize = 15;
}

enum UserRole { admin, user }
