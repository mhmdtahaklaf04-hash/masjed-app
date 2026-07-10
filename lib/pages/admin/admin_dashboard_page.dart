import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import 'manage_announcements_page.dart';
import 'manage_events_page.dart';
import 'manage_audios_page.dart';
import 'manage_gallery_page.dart';
import 'manage_payments_page.dart';
import 'manage_users_page.dart';
import 'send_notification_page.dart';
import 'manage_settings_page.dart';
import 'admin_stats_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_AdminMenuItem>[
      _AdminMenuItem('مدیریت کاربران', Icons.people_outline, const ManageUsersPage()),
      _AdminMenuItem('مدیریت اطلاعیه‌ها', Icons.campaign_outlined, const ManageAnnouncementsPage()),
      _AdminMenuItem('مدیریت برنامه‌ها', Icons.event_note_outlined, const ManageEventsPage()),
      _AdminMenuItem('مدیریت فایل‌های صوتی', Icons.audiotrack_outlined, const ManageAudiosPage()),
      _AdminMenuItem('مدیریت تصاویر', Icons.photo_library_outlined, const ManageGalleryPage()),
      _AdminMenuItem('مدیریت پرداخت‌ها', Icons.payments_outlined, const ManagePaymentsPage()),
      _AdminMenuItem('ارسال اعلان', Icons.notifications_active_outlined, const SendNotificationPage()),
      _AdminMenuItem('مدیریت تنظیمات', Icons.settings_outlined, const ManageSettingsPage()),
      _AdminMenuItem('مشاهده آمار', Icons.bar_chart_outlined, const AdminStatsPage()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل مدیریت'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => item.page));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 34, color: AppColors.primary),
                  const SizedBox(height: 10),
                  Text(item.title, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminMenuItem {
  final String title;
  final IconData icon;
  final Widget page;
  _AdminMenuItem(this.title, this.icon, this.page);
}
