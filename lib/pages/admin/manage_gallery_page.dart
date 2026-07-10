import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/gallery_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class ManageGalleryPage extends StatefulWidget {
  const ManageGalleryPage({super.key});

  @override
  State<ManageGalleryPage> createState() => _ManageGalleryPageState();
}

class _ManageGalleryPageState extends State<ManageGalleryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GalleryProvider>().fetchAll());
  }

  void _openEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _GalleryEditorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت تصاویر')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();
          if (provider.items.isEmpty) {
            return const EmptyStateWidget(message: 'تصویری ثبت نشده است', icon: Icons.photo_library_outlined);
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    left: 2,
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('حذف تصویر'),
                            content: const Text('آیا از حذف این تصویر مطمئن هستید؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
                            ],
                          ),
                        );
                        if (confirm == true) context.read<GalleryProvider>().delete(item);
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _GalleryEditorSheet extends StatefulWidget {
  const _GalleryEditorSheet();

  @override
  State<_GalleryEditorSheet> createState() => _GalleryEditorSheetState();
}

class _GalleryEditorSheetState extends State<_GalleryEditorSheet> {
  final _captionController = TextEditingController();
  File? _pickedImage;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _save() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('یک تصویر انتخاب کنید')),
      );
      return;
    }
    setState(() => _isSaving = true);
    await context.read<GalleryProvider>().create(_pickedImage!, _captionController.text);
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
          Text('افزودن تصویر', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (_pickedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_pickedImage!, height: 150, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(_pickedImage == null ? 'انتخاب تصویر' : 'تغییر تصویر'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _captionController, decoration: const InputDecoration(labelText: 'توضیح (اختیاری)')),
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
