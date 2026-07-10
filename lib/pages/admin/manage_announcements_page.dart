import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/announcement_model.dart';
import '../../providers/announcement_provider.dart';
import '../../services/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

/// نمونهٔ کامل CRUD در پنل مدیریت — این الگو برای مدیریت برنامه‌ها، فایل‌های
/// صوتی، تصاویر و سایر Collectionها نیز قابل استفاده مجدد است.
class ManageAnnouncementsPage extends StatefulWidget {
  const ManageAnnouncementsPage({super.key});

  @override
  State<ManageAnnouncementsPage> createState() => _ManageAnnouncementsPageState();
}

class _ManageAnnouncementsPageState extends State<ManageAnnouncementsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AnnouncementProvider>().fetchInitial());
  }

  void _openEditor({AnnouncementModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AnnouncementEditorSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت اطلاعیه‌ها')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, _) {
          if (provider.state == LoadState.loading) return const LoadingWidget();
          if (provider.announcements.isEmpty) {
            return const EmptyStateWidget(message: 'اطلاعیه‌ای ثبت نشده است');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final item = provider.announcements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openEditor(existing: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('حذف اطلاعیه'),
                              content: const Text('آیا از حذف این اطلاعیه مطمئن هستید؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            context.read<AnnouncementProvider>().delete(item.id);
                          }
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
}

class _AnnouncementEditorSheet extends StatefulWidget {
  final AnnouncementModel? existing;
  const _AnnouncementEditorSheet({this.existing});

  @override
  State<_AnnouncementEditorSheet> createState() => _AnnouncementEditorSheetState();
}

class _AnnouncementEditorSheetState extends State<_AnnouncementEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descController = TextEditingController(text: widget.existing?.description ?? '');
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isSaving = true);

    String imageUrl = widget.existing?.imageUrl ?? '';
    if (_pickedImage != null) {
      imageUrl = await StorageService().uploadFile(_pickedImage!, AppConstants.storageAnnouncements);
    }

    final provider = context.read<AnnouncementProvider>();
    if (widget.existing == null) {
      await provider.create(AnnouncementModel(
        id: '',
        title: _titleController.text,
        description: _descController.text,
        imageUrl: imageUrl,
        date: DateTime.now(),
      ));
    } else {
      await provider.update(AnnouncementModel(
        id: widget.existing!.id,
        title: _titleController.text,
        description: _descController.text,
        imageUrl: imageUrl,
        date: widget.existing!.date,
        isPinned: widget.existing!.isPinned,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'افزودن اطلاعیه' : 'ویرایش اطلاعیه',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان')),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'توضیحات'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(_pickedImage == null ? 'انتخاب تصویر' : 'تصویر انتخاب شد ✓'),
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
    );
  }
}
