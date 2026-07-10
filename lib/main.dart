import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/config/firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'services/notification_service.dart';

import 'providers/auth_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/event_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/prayer_time_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/gallery_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  runApp(const CheraghApp());
}

class CheraghApp extends StatelessWidget {
  const CheraghApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimeProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // تنظیمات سراسری (شماره کارت، اطلاعات تماس، رنگ برنامه) بلافاصله
        // از Firestore خوانده می‌شود تا کل اپ از همان ابتدا رنگ/اطلاعات
        // به‌روز پنل مدیریت را نشان دهد.
        ChangeNotifierProvider(create: (_) => SettingsProvider()..fetch()),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(
              seedColor: settingsProvider.primaryColor,
              secondaryColor: settingsProvider.secondaryColor,
            ),
            darkTheme: AppTheme.darkTheme(
              seedColor: settingsProvider.primaryColor,
              secondaryColor: settingsProvider.secondaryColor,
            ),
            themeMode: themeProvider.themeMode,

            // پشتیبانی کامل از راست‌به‌چپ (RTL)
            locale: const Locale('fa', 'IR'),
            supportedLocales: const [Locale('fa', 'IR')],
            localizationsDelegates: const [
              // در صورت نیاز به لوکالایز کامل ویجت‌های Material/Cupertino،
              // بسته flutter_localizations را اضافه و delegateهای آن را اینجا قرار دهید.
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },

            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
