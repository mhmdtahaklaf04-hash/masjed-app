import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class ManagePaymentsPage extends StatefulWidget {
  const ManagePaymentsPage({super.key});

  @override
  State<ManagePaymentsPage> createState() => _ManagePaymentsPageState();
}

class _ManagePaymentsPageState extends State<ManagePaymentsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PaymentProvider>().fetchAllForAdmin());
  }

  void _viewReceipt(PaymentModel p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: CachedNetworkImage(
          imageUrl: p.receiptUrl,
          placeholder: (_, __) => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) => const SizedBox(
            height: 200,
            child: Icon(Icons.broken_image_outlined, size: 48),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت پرداخت‌ها')),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();
          if (provider.payments.isEmpty) {
            return const EmptyStateWidget(message: 'پرداختی ثبت نشده است', icon: Icons.payments_outlined);
          }
          final sorted = [...provider.payments]..sort((a, b) => b.date.compareTo(a.date));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final p = sorted[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => _viewReceipt(p),
                    child: CircleAvatar(
                      backgroundImage: p.receiptUrl.isNotEmpty ? CachedNetworkImageProvider(p.receiptUrl) : null,
                      child: p.receiptUrl.isEmpty ? const Icon(Icons.receipt_long) : null,
                    ),
                  ),
                  title: Text('${p.userName} • ${p.amount.toStringAsFixed(0)} تومان'),
                  subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(p.date)),
                  trailing: p.status == PaymentStatus.pending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                              onPressed: () => context
                                  .read<PaymentProvider>()
                                  .updateStatus(p.id, PaymentStatus.confirmed),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                              onPressed: () => context
                                  .read<PaymentProvider>()
                                  .updateStatus(p.id, PaymentStatus.rejected),
                            ),
                          ],
                        )
                      : Chip(
                          label: Text(
                            p.status == PaymentStatus.confirmed ? 'تایید شده' : 'رد شده',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          backgroundColor:
                              p.status == PaymentStatus.confirmed ? AppColors.success : AppColors.error,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
