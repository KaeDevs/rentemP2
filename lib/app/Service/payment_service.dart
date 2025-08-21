import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import 'package:rentem/app/Data/Models/payment_model.dart';
import 'package:rentem/app/Data/Models/property_model.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/main.dart';

class PaymentService {
  final Box<PaymentModel> _paymentBox = HiveService.paymentsBox;
  final Box<TenantModel> _tenantBox = HiveService.tenantsBox;
  final Box<PropertyModel> _propertyBox = HiveService.propertiesBox;

  static void verifyInitialized() {
    assert(HiveService.paymentsBox.isOpen, 'HiveService must be initialized first');
  }

  List<PaymentModel> getAll() => _paymentBox.values.toList();

  Future<void> add(PaymentModel payment) async {
    await _paymentBox.add(payment);
  }

  Future<void> update(PaymentModel payment) async {
    await payment.save();
  }

  Future<void> delete(PaymentModel payment) async {
    await payment.delete();
  }

  TenantModel? tenantFor(PaymentModel p) {
    verifyInitialized();
    return _tenantBox.values.firstWhereOrNull((t) => t.id == p.tenantId);
  }

  PropertyModel? propertyForTenant(String tenantId) {
    verifyInitialized();
    final tenant = _tenantBox.values.firstWhereOrNull((t) => t.id == tenantId);
    if (tenant == null || tenant.propertyId == null) return null;
    return _propertyBox.values.firstWhereOrNull((p) => p.id == tenant.propertyId);
  }
}
