import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import 'package:rentem/app/Data/Models/property_model.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/main.dart';

class PropertyService {
  final Box<PropertyModel> _propertyBox = HiveService.propertiesBox;
  final Box<TenantModel> _tenantBox = HiveService.tenantsBox;

  static void verifyInitialized() {
    assert(HiveService.propertiesBox.isOpen, 'HiveService must be initialized first');
  }

  List<PropertyModel> getAll() {
    verifyInitialized();
    return _propertyBox.values.toList();
  }
  List<PropertyModel> get availableProperties =>
      _propertyBox.values.where((p) => !p.isOccupied && p.tenantId == null).toList();

  PropertyModel? getById(String propertyId) {
    verifyInitialized();
    return _propertyBox.values.firstWhereOrNull((p) => p.id == propertyId);
  }

  Future<void> add(PropertyModel property) async {
    await _propertyBox.add(property);
  }

  Future<void> update(PropertyModel property) async {
    await property.save();
  }

  Future<void> delete(PropertyModel property) async {
    // If occupied, unlink tenant
    if (property.tenantId != null) {
      final tenant = _tenantBox.values.firstWhereOrNull((t) => t.id == property.tenantId);
      if (tenant != null) {
        tenant.propertyId = null;
        await tenant.save();
      }
    }
    await property.delete();
  }

  Future<void> assignTenant({required PropertyModel property, required TenantModel tenant}) async {
    // Unassign previous links if any
    if (tenant.propertyId != null) {
      final prev = _propertyBox.values.firstWhere(
        (p) => p.id == tenant.propertyId,
        orElse: () => PropertyModel(
          id: '', address: '', rentAmount: 0, dueDate: DateTime.now(),
        ),
      );
      if (prev.id.isNotEmpty) {
        prev.tenantId = null;
        prev.isOccupied = false;
        await prev.save();
      }
    }

    property.tenantId = tenant.id;
    property.isOccupied = true;
    await property.save();

    tenant.propertyId = property.id;
    await tenant.save();
  }

  Future<void> unassignTenant({required PropertyModel property}) async {
    if (property.tenantId == null) return;
    final tenant = _tenantBox.values.firstWhere(
      (t) => t.id == property.tenantId,
      orElse: () => TenantModel(id: '', name: '', contact: ''),
    );
    property.tenantId = null;
    property.isOccupied = false;
    await property.save();

    if (tenant.id.isNotEmpty) {
      tenant.propertyId = null;
      await tenant.save();
    }
  }
}
