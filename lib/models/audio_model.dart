import 'package:cloud_firestore/cloud_firestore.dart';

class AudioModel {
  final String id;
  final String title;
  final String speaker;
  final String category;
  final String audioUrl;
  final int durationSeconds;
  final DateTime uploadDate;

  AudioModel({
    required this.id,
    required this.title,
    required this.speaker,
    required this.category,
    required this.audioUrl,
    required this.durationSeconds,
    required this.uploadDate,
  });

  factory AudioModel.fromMap(String id, Map<String, dynamic> map) {
    return AudioModel(
      id: id,
      title: map['title'] ?? '',
      speaker: map['speaker'] ?? '',
      category: map['category'] ?? 'عمومی',
      audioUrl: map['audioUrl'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      uploadDate: (map['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'speaker': speaker,
      'category': category,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'uploadDate': Timestamp.fromDate(uploadDate),
    };
  }
}
