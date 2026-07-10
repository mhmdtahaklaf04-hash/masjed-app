import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NotificationProvider>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اعلان‌ها')),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();
          final items = provider.visibleNotifications;
          if (items.isEmpty) {
            return const EmptyStateWidget(
              message: 'اعلانی برای نمایش وجود ندارد',
              icon: Icons.notifications_none_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: provider.fetchAll,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final n = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withOpacity(0.15),
                      child: const Icon(Icons.notifications, color: AppColors.secondary),
                    ),
                    title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(n.body),
                    trailing: Text(
                      DateFormat('MM/dd HH:mm').format(n.date),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
