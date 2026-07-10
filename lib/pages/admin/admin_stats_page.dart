import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../widgets/loading_widget.dart';

/// نمایش آمار کلی برنامه: تعداد کاربران، اطلاعیه‌ها، برنامه‌ها، فایل‌های صوتی
/// تصاویر گالری و پرداخت‌های در انتظار بررسی.
class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  final FirestoreService _service = FirestoreService();
  bool _isLoading = true;
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final collections = {
      'کاربران': AppConstants.usersCollection,
      'اطلاعیه‌ها': AppConstants.announcementsCollection,
      'برنامه‌های هیئت': AppConstants.eventsCollection,
      'فایل‌های صوتی': AppConstants.audiosCollection,
      'تصاویر گالری': AppConstants.galleryCollection,
      'پرداخت‌ها': AppConstants.paymentsCollection,
      'اعلان‌های ارسالی': AppConstants.notificationsCollection,
    };
    final result = <String, int>{};
    for (final entry in collections.entries) {
      try {
        final snap = await _service.collection(entry.value).get();
        result[entry.key] = snap.docs.length;
      } catch (_) {
        result[entry.key] = 0;
      }
    }
    if (mounted) setState(() {
      _counts = result;
      _isLoading = false;
    });
  }

  static const _icons = {
    'کاربران': Icons.people_outline,
    'اطلاعیه‌ها': Icons.campaign_outlined,
    'برنامه‌های هیئت': Icons.event_note_outlined,
    'فایل‌های صوتی': Icons.audiotrack_outlined,
    'تصاویر گالری': Icons.photo_library_outlined,
    'پرداخت‌ها': Icons.payments_outlined,
    'اعلان‌های ارسالی': Icons.notifications_active_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مشاهده آمار'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _counts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final key = _counts.keys.elementAt(index);
                final value = _counts[key]!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_icons[key], size: 30, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Text(
                          '$value',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(key, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
