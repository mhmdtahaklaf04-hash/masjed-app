import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/payment_model.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  final _amountController = TextEditingController();
  File? _receiptImage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SettingsProvider>().fetch());
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _receiptImage = File(picked.path));
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا وارد حساب کاربری شوید')),
      );
      return;
    }
    if (_receiptImage == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مبلغ و تصویر رسید را وارد کنید')),
      );
      return;
    }
    final ok = await context.read<PaymentProvider>().submitReceipt(
          userId: auth.currentUser!.uid,
          userName: auth.currentUser!.name,
          amount: double.tryParse(_amountController.text) ?? 0,
          receiptImage: _receiptImage!,
        );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رسید با موفقیت ثبت شد')),
      );
      setState(() {
        _receiptImage = null;
        _amountController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کمک‌های مالی')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              final cardNumber = settingsProvider.settings.cardNumber;
              final holderName = settingsProvider.settings.cardHolderName;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('شماره کارت هیئت', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cardNumber, style: const TextStyle(fontSize: 18, letterSpacing: 1)),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: cardNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('شماره کارت کپی شد')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(holderName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: cardNumber,
                        size: 150,
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text('ثبت رسید پرداخت', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'مبلغ (تومان)'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(_receiptImage == null ? 'انتخاب تصویر رسید' : 'تصویر انتخاب شد ✓'),
          ),
          const SizedBox(height: 16),
          Consumer<PaymentProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isSubmitting ? null : _submit,
              child: provider.isSubmitting
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('ثبت رسید'),
            ),
          ),
          const SizedBox(height: 28),
          Text('تاریخچه پرداخت‌ها', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Consumer2<AuthProvider, PaymentProvider>(
            builder: (context, auth, provider, _) {
              if (auth.currentUser == null) {
                return const Text('برای مشاهده تاریخچه وارد شوید.');
              }
              return FutureBuilder(
                future: provider.fetchUserPayments(auth.currentUser!.uid),
                builder: (context, snapshot) {
                  if (provider.payments.isEmpty) {
                    return const Text('پرداختی ثبت نشده است.');
                  }
                  return Column(
                    children: provider.payments.map((p) => _paymentTile(p)).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(PaymentModel p) {
    Color statusColor;
    String statusText;
    switch (p.status) {
      case PaymentStatus.confirmed:
        statusColor = AppColors.success;
        statusText = 'تایید شده';
        break;
      case PaymentStatus.rejected:
        statusColor = AppColors.error;
        statusText = 'رد شده';
        break;
      default:
        statusColor = AppColors.warning;
        statusText = 'در انتظار بررسی';
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${p.amount.toStringAsFixed(0)} تومان'),
        subtitle: Text(DateFormat('yyyy/MM/dd').format(p.date)),
        trailing: Chip(
          label: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: statusColor,
        ),
      ),
    );
  }
}
