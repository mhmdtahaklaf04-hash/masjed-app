import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/announcement_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'announcement_detail_page.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AnnouncementProvider>().fetchInitial(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اطلاعیه‌ها')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'جستجو در اطلاعیه‌ها...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Consumer<AnnouncementProvider>(
              builder: (context, provider, _) {
                if (provider.state == LoadState.loading) {
                  return const LoadingWidget();
                }
                final list = provider.filterByQuery(_query);
                if (list.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'اطلاعیه‌ای یافت نشد',
                    icon: Icons.campaign_outlined,
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                      provider.fetchMore();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: provider.fetchInitial,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnnouncementDetailPage(item: item),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (item.imageUrl.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      height: 160,
                                      color: Colors.grey.shade200,
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      height: 160,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat('yyyy/MM/dd').format(item.date),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.grey),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.share_outlined, size: 20),
                                            onPressed: () => Share.share(
                                              '${item.title}\n\n${item.description}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
