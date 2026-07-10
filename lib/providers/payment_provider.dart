import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class PaymentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  Future<void> fetchUserPayments(String userId) async {
    _isLoading = true;
    notifyListeners();
    final snap = await _firestoreService.streamCollection(
      AppConstants.paymentsCollection,
    ).first;
    _payments = snap.docs
        .map((d) => PaymentModel.fromMap(d.id, d.data()))
        .where((p) => p.userId == userId)
        .toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllForAdmin() async {
    _isLoading = true;
    notifyListeners();
    final snap = await _firestoreService.streamCollection(
      AppConstants.paymentsCollection,
    ).first;
    _payments = snap.docs.map((d) => PaymentModel.fromMap(d.id, d.data())).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitReceipt({
    required String userId,
    required String userName,
    required double amount,
    required File receiptImage,
    String? note,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final url = await _storageService.uploadFile(
        receiptImage,
        AppConstants.storageReceipts,
      );
      final payment = PaymentModel(
        id: '',
        userId: userId,
        userName: userName,
        amount: amount,
        receiptUrl: url,
        status: PaymentStatus.pending,
        date: DateTime.now(),
        note: note,
      );
      await _firestoreService.create(
        AppConstants.paymentsCollection,
        payment.toMap(),
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(String id, PaymentStatus status) async {
    await _firestoreService.update(
      AppConstants.paymentsCollection,
      id,
      {'status': status.name},
    );
    final idx = _payments.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final old = _payments[idx];
      _payments[idx] = PaymentModel(
        id: old.id,
        userId: old.userId,
        userName: old.userName,
        amount: old.amount,
        receiptUrl: old.receiptUrl,
        status: status,
        date: old.date,
        note: old.note,
      );
      notifyListeners();
    }
  }
}
