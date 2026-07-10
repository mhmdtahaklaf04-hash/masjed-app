import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/gallery_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class GalleryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<GalleryModel> _items = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<GalleryModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _firestoreService.streamCollection(
        AppConstants.galleryCollection,
      ).first;
      _items = snap.docs.map((d) => GalleryModel.fromMap(d.id, d.data())).toList();
    } catch (_) {
      _items = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> create(File image, String caption) async {
    _isSaving = true;
    notifyListeners();
    try {
      final url = await _storageService.uploadFile(image, AppConstants.storageGallery);
      final item = GalleryModel(
        id: '',
        imageUrl: url,
        caption: caption,
        date: DateTime.now(),
      );
      await _firestoreService.create(AppConstants.galleryCollection, item.toMap());
      _isSaving = false;
      notifyListeners();
      await fetchAll();
      return true;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> delete(GalleryModel item) async {
    await _firestoreService.delete(AppConstants.galleryCollection, item.id);
    await _storageService.deleteFile(item.imageUrl);
    _items.removeWhere((g) => g.id == item.id);
    notifyListeners();
  }
}
