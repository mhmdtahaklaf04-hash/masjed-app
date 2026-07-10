import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/announcement_model.dart';
import '../services/firestore_service.dart';

enum LoadState { idle, loading, loaded, empty, error }

class AnnouncementProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<AnnouncementModel> _announcements = [];
  LoadState _state = LoadState.idle;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  List<AnnouncementModel> get announcements => _announcements;
  LoadState get state => _state;
  bool get hasMore => _hasMore;

  Future<void> fetchInitial() async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      final snap = await _service.getPaginated(
        AppConstants.announcementsCollection,
      );
      _announcements = snap.docs
          .map((d) => AnnouncementModel.fromMap(d.id, d.data()))
          .toList();
      _lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
      _hasMore = snap.docs.length == AppConstants.pageSize;
      _state = _announcements.isEmpty ? LoadState.empty : LoadState.loaded;
    } catch (e) {
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _lastDoc == null) return;
    final snap = await _service.getPaginated(
      AppConstants.announcementsCollection,
      startAfter: _lastDoc,
    );
    _announcements.addAll(
      snap.docs.map((d) => AnnouncementModel.fromMap(d.id, d.data())),
    );
    _lastDoc = snap.docs.isNotEmpty ? snap.docs.last : _lastDoc;
    _hasMore = snap.docs.length == AppConstants.pageSize;
    notifyListeners();
  }

  Future<void> create(AnnouncementModel item) async {
    await _service.create(AppConstants.announcementsCollection, item.toMap());
    await fetchInitial();
  }

  Future<void> update(AnnouncementModel item) async {
    await _service.update(
      AppConstants.announcementsCollection,
      item.id,
      item.toMap(),
    );
    await fetchInitial();
  }

  Future<void> delete(String id) async {
    await _service.delete(AppConstants.announcementsCollection, id);
    _announcements.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  List<AnnouncementModel> filterByQuery(String query) {
    if (query.isEmpty) return _announcements;
    return _announcements
        .where((a) => a.title.contains(query) || a.description.contains(query))
        .toList();
  }
}
