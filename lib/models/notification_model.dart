import 'package:cloud_firestore/cloud_firestore.dart';

/// مقصد ارسال اعلان: همه کاربران یا یک گروه خاص (بر اساس topic)
enum NotificationTarget { all, group }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final DateTime? scheduledAt;
  final NotificationTarget target;
  final String? groupName;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.scheduledAt,
    this.target = NotificationTarget.all,
    this.groupName,
  });

  bool get isScheduled => scheduledAt != null && scheduledAt!.isAfter(DateTime.now());

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate(),
      target: NotificationTarget.values.firstWhere(
        (e) => e.name == map['target'],
        orElse: () => NotificationTarget.all,
      ),
      groupName: map['groupName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'date': Timestamp.fromDate(date),
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'target': target.name,
      'groupName': groupName,
    };
  }
}
