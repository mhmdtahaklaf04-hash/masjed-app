import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class LecturesPage extends StatefulWidget {
  const LecturesPage({super.key});

  @override
  State<LecturesPage> createState() => _LecturesPageState();
}

class _LecturesPageState extends State<LecturesPage> {
  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AudioProvider>().fetchAll());
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(String id, String url) async {
    if (_playingId == id) {
      await _player.stop();
      setState(() => _playingId = null);
    } else {
      await _player.setUrl(url);
      _player.play();
      setState(() => _playingId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سخنرانی‌ها')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'جستجوی سخنرانی یا سخنران...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Consumer<AudioProvider>(
            builder: (context, provider, _) {
              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: provider.categories.map((cat) {
                    final selected = provider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) => provider.setCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<AudioProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const LoadingWidget();
                final list = provider.search(_query);
                if (list.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'سخنرانی‌ای یافت نشد',
                    icon: Icons.mic_off_outlined,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final a = list[index];
                    final isPlaying = _playingId == a.id;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                        title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${a.speaker} • ${a.category}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_outlined),
                          onPressed: () async {
                            // دانلود از طریق مرورگر/مدیر دانلود دستگاه انجام می‌شود
                            final uri = Uri.parse(a.audioUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        onTap: () => _togglePlay(a.id, a.audioUrl),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
