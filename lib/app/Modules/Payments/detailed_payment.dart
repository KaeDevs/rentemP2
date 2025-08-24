import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rentem/main.dart';
import 'package:rentem/app/Data/Models/payment_model.dart';
import '../../Utils/font_styles.dart';

class DetailedPayment extends ConsumerWidget {
  final PaymentModel payment;
  const DetailedPayment({super.key, required this.payment});

  void _deletePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this payment record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              payment.delete();
              context.pop();
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Details',
          style: FontStyles.heading.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.pushNamed('addpayment', extra: payment),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePayment(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailCard(
              theme: theme,
              items: [
                _DetailItem(
                  label: 'Amount Paid',
                  value: formatter.format(payment.amount),
                  icon: Icons.currency_rupee,
                ),
                _DetailItem(
                  label: 'Date Paid',
                  value: DateFormat('dd MMM yyyy').format(payment.datePaid),
                  icon: Icons.calendar_today,
                ),
                _DetailItem(
                  label: 'Month Year',
                  value: payment.monthYear,
                  icon: Icons.date_range,
                ),
                _DetailItem(
                  label: 'Penalty Amount',
                  value: formatter.format(payment.penalty),
                  icon: Icons.money_off,
                ),
                _DetailItem(
                  label: 'Description',
                  value: payment.description,
                  icon: Icons.description,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final ThemeData theme;
  final List<_DetailItem> items;

  const _DetailCard({required this.theme, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(item.icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: FontStyles.body.copyWith(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        item.value,
                        style: FontStyles.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
