import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rentem/main.dart';
import 'package:rentem/app/Data/Models/payment_model.dart';
import '../../Utils/font_styles.dart';

class PaymentsView extends ConsumerWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tenants = HiveService.tenantsBox;
    final properties = HiveService.propertiesBox;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payments',
          style: FontStyles.heading.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.secondary,
        elevation: 0,
      ),
      body: ValueListenableBuilder<Box<PaymentModel>>(
        valueListenable: HiveService.paymentsBox.listenable(),
        builder: (context, Box<PaymentModel> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No payments recorded',
                style: FontStyles.body.copyWith(
                  fontSize: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final payment = box.getAt(index);
              if (payment == null) return const SizedBox();

              // lookup tenant
              final tenant = tenants.values.firstWhere(
                (t) => t.id == payment.tenantId,
                
              );
              final tenantName = tenant?.name ?? 'Unknown Tenant';

              // lookup property (via tenant.propertyId)
              final propertyName = tenant?.propertyId != null
                  ? (properties.get(tenant!.propertyId)?.name ??
                        'Unknown Property')
                  : 'Unassigned Property';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.payment,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    '₹${payment.amount.toStringAsFixed(2)}',
                    style: FontStyles.heading.copyWith(fontSize: 18),
                  ),
                  subtitle: Text(
                    '$tenantName • $propertyName',
                    style: FontStyles.body.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  onTap: () =>
                      context.pushNamed('paymentdetails', extra: payment),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('addpayment'),
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}
