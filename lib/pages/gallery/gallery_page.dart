import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/gallery_model.dart';
import '../../providers/gallery_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GalleryProvider>().fetchAll());
  }

  void _openViewer(GalleryModel item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const SizedBox(
                  height: 240,
                  child: Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (item.caption.isNotEmpty)
                    Text(item.caption, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy/MM/dd').format(item.date),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => Share.share(item.imageUrl),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('اشتراک‌گذاری'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گالری تصاویر')),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();
          if (provider.items.isEmpty) {
            return const EmptyStateWidget(
              message: 'هنوز تصویری در گالری ثبت نشده است',
              icon: Icons.photo_library_outlined,
            );
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
              return GestureDetector(
                onTap: () => _openViewer(item),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
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
