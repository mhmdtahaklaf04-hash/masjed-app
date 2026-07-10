import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/gallery_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../gallery/gallery_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GalleryProvider>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درباره هیئت')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(context, 'تاریخچه',
              'هیئت بابالحوائج زمان‌آباد سال‌هاست که با همت اهالی محله برگزار می‌شود و پذیرای عاشقان اهل‌بیت (ع) است.'),
          _section(context, 'اهداف',
              'ترویج فرهنگ اهل‌بیت (ع)، کمک به نیازمندان، برگزاری مراسم مذهبی و ایجاد همبستگی میان اعضای محله.'),
          _section(context, 'معرفی مسئولین',
              'مسئول هیئت، هیئت امنا و گروه اجرایی که با تلاش داوطلبانه در خدمت برنامه‌ها هستند.'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('گالری تصاویر', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GalleryPage()),
                ),
                child: const Text('مشاهده همه'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Consumer<GalleryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (provider.items.isEmpty) {
                return const EmptyStateWidget(
                  message: 'هنوز تصویری اضافه نشده است',
                  icon: Icons.photo_library_outlined,
                );
              }
              final preview = provider.items.take(6).toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: preview.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: preview[index].imageUrl,
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
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
