import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final bool isPinned;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    this.isPinned = false,
  });

  factory AnnouncementModel.fromMap(String id, Map<String, dynamic> map) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPinned: map['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'isPinned': isPinned,
    };
  }
}
