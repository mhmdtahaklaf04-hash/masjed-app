import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, confirmed, rejected }

class PaymentModel {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String receiptUrl;
  final PaymentStatus status;
  final DateTime date;
  final String? note;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.receiptUrl,
    required this.status,
    required this.date,
    this.note,
  });

  factory PaymentModel.fromMap(String id, Map<String, dynamic> map) {
    return PaymentModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      receiptUrl: map['receiptUrl'] ?? '',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'receiptUrl': receiptUrl,
      'status': status.name,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
