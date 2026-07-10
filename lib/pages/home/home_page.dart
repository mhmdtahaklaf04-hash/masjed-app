import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/menu_card.dart';
import '../announcements/announcements_page.dart';
import '../events/events_page.dart';
import '../prayer_times/prayer_times_page.dart';
import '../lectures/lectures_page.dart';
import '../donations/donations_page.dart';
import '../contact/contact_page.dart';
import '../about/about_page.dart';
import '../notifications/notifications_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = <_MenuItem>[
      _MenuItem('اوقات شرعی', Icons.access_time_filled, const PrayerTimesPage()),
      _MenuItem('برنامه‌های هیئت', Icons.event, const EventsPage()),
      _MenuItem('اطلاعیه‌ها', Icons.campaign, const AnnouncementsPage()),
      _MenuItem('سخنرانی‌ها', Icons.mic, const LecturesPage()),
      _MenuItem('کمک‌های مالی', Icons.volunteer_activism, const DonationsPage()),
      _MenuItem('تماس با ما', Icons.phone_in_talk, const ContactPage()),
      _MenuItem('درباره هیئت', Icons.info_outline, const AboutPage()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(AppConstants.appName),
            Text(
              AppConstants.appSubtitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return MenuCard(
              title: item.title,
              icon: item.icon,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item.page),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget page;
  _MenuItem(this.title, this.icon, this.page);
}
