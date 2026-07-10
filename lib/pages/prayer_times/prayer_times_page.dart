import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/prayer_time_provider.dart';
import '../../widgets/loading_widget.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PrayerTimeProvider>().refresh());
  }

  Widget _timeRow(String label, DateTime? time, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          time != null ? DateFormat('HH:mm').format(time) : '--:--',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اوقات شرعی'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PrayerTimeProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<PrayerTimeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.times == null) {
            return const LoadingWidget(message: 'در حال محاسبه اوقات شرعی...');
          }
          final t = provider.times!;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Center(
                child: Text(
                  DateFormat('yyyy/MM/dd', 'fa').format(DateTime.now()),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              _timeRow('اذان صبح', t.fajr, Icons.brightness_3),
              _timeRow('طلوع آفتاب', t.sunrise, Icons.wb_sunny_outlined),
              _timeRow('اذان ظهر', t.dhuhr, Icons.wb_sunny),
              _timeRow('غروب آفتاب', t.sunset, Icons.brightness_4),
              _timeRow('اذان مغرب', t.maghrib, Icons.nightlight_round),
              _timeRow('نیمه شب شرعی', t.midnight, Icons.bedtime),
            ],
          );
        },
      ),
    );
  }
}
