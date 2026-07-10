import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryModel {
  final String id;
  final String imageUrl;
  final String caption;
  final DateTime date;

  GalleryModel({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.date,
  });

  factory GalleryModel.fromMap(String id, Map<String, dynamic> map) {
    return GalleryModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
      'date': Timestamp.fromDate(date),
    };
  }
}
