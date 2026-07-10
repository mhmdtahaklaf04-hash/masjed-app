import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => context.read<EventProvider>().fetchAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildList(List<EventModel> items) {
    if (items.isEmpty) {
      return const EmptyStateWidget(message: 'برنامه‌ای ثبت نشده است', icon: Icons.event_busy);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final e = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${e.location}\n${DateFormat('yyyy/MM/dd - HH:mm').format(e.dateTime)}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('برنامه‌های هیئت'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'روزانه'), Tab(text: 'هفتگی'), Tab(text: 'ماهانه')],
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.byFrequency(EventFrequency.daily)),
              _buildList(provider.byFrequency(EventFrequency.weekly)),
              _buildList(provider.byFrequency(EventFrequency.monthly)),
            ],
          );
        },
      ),
    );
  }
}
