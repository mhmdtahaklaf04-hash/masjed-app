import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state_widget.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _groupController = TextEditingController();
  NotificationTarget _target = NotificationTarget.all;
  DateTime? _scheduledAt;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NotificationProvider>().fetchAll());
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _send() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان و متن اعلان الزامی است')),
      );
      return;
    }
    final notification = NotificationModel(
      id: '',
      title: _titleController.text,
      body: _bodyController.text,
      date: DateTime.now(),
      scheduledAt: _scheduledAt,
      target: _target,
      groupName: _target == NotificationTarget.group ? _groupController.text : null,
    );
    final ok = await context.read<NotificationProvider>().send(notification);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اعلان با موفقیت ثبت و ارسال شد')),
      );
      _titleController.clear();
      _bodyController.clear();
      _groupController.clear();
      setState(() {
        _scheduledAt = null;
        _target = NotificationTarget.all;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ارسال اعلان')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان اعلان')),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'متن اعلان'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<NotificationTarget>(
            segments: const [
              ButtonSegment(value: NotificationTarget.all, label: Text('همه کاربران'), icon: Icon(Icons.public)),
              ButtonSegment(value: NotificationTarget.group, label: Text('گروه خاص'), icon: Icon(Icons.group_outlined)),
            ],
            selected: {_target},
            onSelectionChanged: (s) => setState(() => _target = s.first),
          ),
          if (_target == NotificationTarget.group) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _groupController,
              decoration: const InputDecoration(labelText: 'نام گروه (topic)'),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickSchedule,
            icon: const Icon(Icons.schedule_outlined),
            label: Text(
              _scheduledAt == null
                  ? 'ارسال فوری (بدون زمان‌بندی)'
                  : 'زمان‌بندی‌شده برای ${DateFormat('yyyy/MM/dd HH:mm').format(_scheduledAt!)}',
            ),
          ),
          if (_scheduledAt != null)
            TextButton(
              onPressed: () => setState(() => _scheduledAt = null),
              child: const Text('حذف زمان‌بندی'),
            ),
          const SizedBox(height: 16),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isSending ? null : _send,
                child: provider.isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('ارسال اعلان'),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('اعلان‌های ارسال‌شده', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isEmpty) {
                return const EmptyStateWidget(message: 'هنوز اعلانی ارسال نشده', icon: Icons.notifications_none);
              }
              final sorted = [...provider.notifications]..sort((a, b) => b.date.compareTo(a.date));
              return Column(
                children: sorted
                    .map((n) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(n.title),
                            subtitle: Text(n.body),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => context.read<NotificationProvider>().delete(n.id),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
