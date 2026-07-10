import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/audio_model.dart';
import '../services/firestore_service.dart';

class AudioProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<AudioModel> _audios = [];
  bool _isLoading = false;
  String _selectedCategory = 'همه';

  List<AudioModel> get isLoadingAudios => _audios;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<AudioModel> get filtered {
    if (_selectedCategory == 'همه') return _audios;
    return _audios.where((a) => a.category == _selectedCategory).toList();
  }

  List<String> get categories =>
      ['همه', ..._audios.map((a) => a.category).toSet()];

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    final snap = await _service.streamCollection(
      AppConstants.audiosCollection,
      orderBy: 'uploadDate',
    ).first;
    _audios = snap.docs.map((d) => AudioModel.fromMap(d.id, d.data())).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> create(AudioModel audio) async {
    await _service.create(AppConstants.audiosCollection, audio.toMap());
    await fetchAll();
  }

  Future<void> delete(String id) async {
    await _service.delete(AppConstants.audiosCollection, id);
    _audios.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  List<AudioModel> search(String query) {
    if (query.isEmpty) return filtered;
    return filtered
        .where((a) =>
            a.title.contains(query) || a.speaker.contains(query))
        .toList();
  }
}
