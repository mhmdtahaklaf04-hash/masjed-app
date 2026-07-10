import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EventProvider>().fetchAll());
  }

  void _openEditor({EventModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EventEditorSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت برنامه‌های هیئت')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();
          if (provider.events.isEmpty) {
            return const EmptyStateWidget(message: 'برنامه‌ای ثبت نشده است');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              final e = provider.events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(e.title),
                  subtitle: Text(
                    '${_freqLabel(e.frequency)} • ${e.location}\n${DateFormat('yyyy/MM/dd HH:mm').format(e.dateTime)}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openEditor(existing: e),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('حذف برنامه'),
                              content: const Text('آیا از حذف این برنامه مطمئن هستید؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
                              ],
                            ),
                          );
                          if (confirm == true) context.read<EventProvider>().delete(e.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _freqLabel(EventFrequency f) {
    switch (f) {
      case EventFrequency.daily:
        return 'روزانه';
      case EventFrequency.weekly:
        return 'هفتگی';
      case EventFrequency.monthly:
        return 'ماهانه';
    }
  }
}

class _EventEditorSheet extends StatefulWidget {
  final EventModel? existing;
  const _EventEditorSheet({this.existing});

  @override
  State<_EventEditorSheet> createState() => _EventEditorSheetState();
}

class _EventEditorSheetState extends State<_EventEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _locationController;
  late DateTime _dateTime;
  late EventFrequency _frequency;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descController = TextEditingController(text: widget.existing?.description ?? '');
    _locationController = TextEditingController(text: widget.existing?.location ?? '');
    _dateTime = widget.existing?.dateTime ?? DateTime.now();
    _frequency = widget.existing?.frequency ?? EventFrequency.weekly;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isSaving = true);
    final provider = context.read<EventProvider>();
    if (widget.existing == null) {
      await provider.create(EventModel(
        id: '',
        title: _titleController.text,
        description: _descController.text,
        dateTime: _dateTime,
        frequency: _frequency,
        location: _locationController.text,
      ));
    } else {
      await provider.update(EventModel(
        id: widget.existing!.id,
        title: _titleController.text,
        description: _descController.text,
        dateTime: _dateTime,
        frequency: _frequency,
        location: _locationController.text,
      ));
    }
    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? 'افزودن برنامه' : 'ویرایش برنامه',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان')),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'توضیحات'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'مکان')),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventFrequency>(
              value: _frequency,
              decoration: const InputDecoration(labelText: 'دوره تکرار'),
              items: const [
                DropdownMenuItem(value: EventFrequency.daily, child: Text('روزانه')),
                DropdownMenuItem(value: EventFrequency.weekly, child: Text('هفتگی')),
                DropdownMenuItem(value: EventFrequency.monthly, child: Text('ماهانه')),
              ],
              onChanged: (v) => setState(() => _frequency = v ?? EventFrequency.weekly),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(DateFormat('yyyy/MM/dd HH:mm').format(_dateTime)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('ذخیره'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
