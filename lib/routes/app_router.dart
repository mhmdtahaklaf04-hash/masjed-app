import 'package:flutter/material.dart';
import '../pages/splash/splash_page.dart';
import '../pages/home/home_page.dart';
import '../pages/announcements/announcements_page.dart';
import '../pages/events/events_page.dart';
import '../pages/prayer_times/prayer_times_page.dart';
import '../pages/lectures/lectures_page.dart';
import '../pages/donations/donations_page.dart';
import '../pages/contact/contact_page.dart';
import '../pages/about/about_page.dart';
import '../pages/admin/admin_login_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/gallery/gallery_page.dart';
import '../pages/notifications/notifications_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String announcements = '/announcements';
  static const String events = '/events';
  static const String prayerTimes = '/prayer-times';
  static const String lectures = '/lectures';
  static const String donations = '/donations';
  static const String contact = '/contact';
  static const String about = '/about';
  static const String gallery = '/gallery';
  static const String notifications = '/notifications';
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        home: (_) => const HomePage(),
        announcements: (_) => const AnnouncementsPage(),
        events: (_) => const EventsPage(),
        prayerTimes: (_) => const PrayerTimesPage(),
        lectures: (_) => const LecturesPage(),
        donations: (_) => const DonationsPage(),
        contact: (_) => const ContactPage(),
        about: (_) => const AboutPage(),
        gallery: (_) => const GalleryPage(),
        notifications: (_) => const NotificationsPage(),
        adminLogin: (_) => const AdminLoginPage(),
        adminDashboard: (_) => const AdminDashboardPage(),
      };
}
