import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/main.dart';

class TenantService {
  final Box<TenantModel> _tenantBox = HiveService.tenantsBox;

  static void verifyInitialized() {
    assert(HiveService.tenantsBox.isOpen, 'HiveService must be initialized first');
  }

  List<TenantModel> getAll() {
    verifyInitialized();
    return _tenantBox.values.toList();
  }

  Future<void> add(TenantModel tenant) async {
    verifyInitialized();
    await _tenantBox.add(tenant);
  }

  Future<void> update(TenantModel tenant) async {
    verifyInitialized();
    await tenant.save();
  }

  Future<void> delete(TenantModel tenant) async {
    verifyInitialized();
    await tenant.delete();
  }

  TenantModel? getById(String tenantId) {
    verifyInitialized();
    return _tenantBox.values.firstWhereOrNull((t) => t.id == tenantId);
  }
}
