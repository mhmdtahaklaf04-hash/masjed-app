import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<EventModel> _events = [];
  bool _isLoading = false;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;

  List<EventModel> byFrequency(EventFrequency freq) =>
      _events.where((e) => e.frequency == freq).toList();

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    final snap = await _service.streamCollection(
      AppConstants.eventsCollection,
      orderBy: 'dateTime',
      descending: false,
    ).first;
    _events = snap.docs.map((d) => EventModel.fromMap(d.id, d.data())).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> create(EventModel event) async {
    await _service.create(AppConstants.eventsCollection, event.toMap());
    await fetchAll();
  }

  Future<void> update(EventModel event) async {
    await _service.update(AppConstants.eventsCollection, event.id, event.toMap());
    await fetchAll();
  }

  Future<void> delete(String id) async {
    await _service.delete(AppConstants.eventsCollection, id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
