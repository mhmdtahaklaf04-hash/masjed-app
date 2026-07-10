import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/announcement_model.dart';

class AnnouncementDetailPage extends StatelessWidget {
  final AnnouncementModel item;
  const AnnouncementDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات اطلاعیه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share('${item.title}\n\n${item.description}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('yyyy/MM/dd - HH:mm').format(item.date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(height: 32),
                  Text(item.description, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
