import 'package:cloud_firestore/cloud_firestore.dart';

enum EventFrequency { daily, weekly, monthly }

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final EventFrequency frequency;
  final String location;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.frequency,
    required this.location,
  });

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: (map['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      frequency: EventFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => EventFrequency.weekly,
      ),
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'frequency': frequency.name,
      'location': location,
    };
  }
}
