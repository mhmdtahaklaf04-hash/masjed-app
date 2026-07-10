import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/audio_model.dart';
import '../../providers/audio_provider.dart';
import '../../services/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class ManageAudiosPage extends StatefulWidget {
  const ManageAudiosPage({super.key});

  @override
  State<ManageAudiosPage> createState() => _ManageAudiosPageState();
}

class _ManageAudiosPageState extends State<ManageAudiosPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AudioProvider>().fetchAll());
  }

  void _openEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AudioEditorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت فایل‌های صوتی')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        child: const Icon(Icons.add),
      ),
      body: Consumer<AudioProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();
          final list = provider.isLoadingAudios;
          if (list.isEmpty) {
            return const EmptyStateWidget(message: 'فایل صوتی ثبت نشده است', icon: Icons.audiotrack_outlined);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final a = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.mic)),
                  title: Text(a.title),
                  subtitle: Text('${a.speaker} • ${a.category}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('حذف فایل صوتی'),
                          content: const Text('آیا از حذف این فایل مطمئن هستید؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
                          ],
                        ),
                      );
                      if (confirm == true) context.read<AudioProvider>().delete(a.id);
                    },
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

class _AudioEditorSheet extends StatefulWidget {
  const _AudioEditorSheet();

  @override
  State<_AudioEditorSheet> createState() => _AudioEditorSheetState();
}

class _AudioEditorSheetState extends State<_AudioEditorSheet> {
  final _titleController = TextEditingController();
  final _speakerController = TextEditingController();
  final _categoryController = TextEditingController(text: 'عمومی');
  File? _pickedFile;
  String? _pickedFileName;
  bool _isSaving = false;

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _pickedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان و فایل صوتی الزامی است')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final url = await StorageService().uploadFile(_pickedFile!, AppConstants.storageAudios);
    await context.read<AudioProvider>().create(AudioModel(
          id: '',
          title: _titleController.text,
          speaker: _speakerController.text,
          category: _categoryController.text.isEmpty ? 'عمومی' : _categoryController.text,
          audioUrl: url,
          durationSeconds: 0,
          uploadDate: DateTime.now(),
        ));
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
          Text('افزودن فایل صوتی', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان سخنرانی')),
          const SizedBox(height: 12),
          TextField(controller: _speakerController, decoration: const InputDecoration(labelText: 'نام سخنران')),
          const SizedBox(height: 12),
          TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'دسته‌بندی')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickAudio,
            icon: const Icon(Icons.audio_file_outlined),
            label: Text(_pickedFileName ?? 'انتخاب فایل صوتی'),
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
