import 'package:hive/hive.dart';

part 'property_model.g.dart';

@HiveType(typeId: 2)
class PropertyModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String address;

  @HiveField(2)
  double rentAmount;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  String? tenantId; // Made nullable for unoccupied properties

  @HiveField(5)
  DateTime? leaseStart; // Made nullable

  @HiveField(6)
  DateTime? leaseEnd; // Made nullable

  @HiveField(7)
  String? agreementFilePath;

  @HiveField(8)
  List<String>? pics;

  @HiveField(9)
  String? name;

  @HiveField(10)
  bool isOccupied; // Track occupancy status

  @HiveField(11)
  String? propertyType; // House, Apartment, etc.

  PropertyModel({
    required this.id,
    required this.address,
    required this.rentAmount,
    required this.dueDate,
    this.tenantId,
    this.leaseStart,
    this.leaseEnd,
    this.agreementFilePath,
    this.pics,
    this.name,
    this.isOccupied = false,
    this.propertyType,
  });

  // Helper method to check if property is available
  bool get isAvailable => !isOccupied && tenantId == null;
}
