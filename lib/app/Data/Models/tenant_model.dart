import 'package:hive/hive.dart';

part 'tenant_model.g.dart';

@HiveType(typeId: 3)
class TenantModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String contact;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? propertyId; // Link to property

  @HiveField(5)
  DateTime? moveInDate;

  @HiveField(6)
  String? emergencyContact;

  @HiveField(7)
  String? occupation;

  @HiveField(8)
  double? securityDeposit;

  TenantModel({
    required this.id,
    required this.name,
    required this.contact,
    this.email,
    this.propertyId,
    this.moveInDate,
    this.emergencyContact,
    this.occupation,
    this.securityDeposit,
  });
}
