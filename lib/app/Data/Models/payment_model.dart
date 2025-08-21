import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 4)
class PaymentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tenantId;

  @HiveField(2)
  DateTime datePaid;

  @HiveField(3)
  double amount;

  @HiveField(4)
  double penalty;

  @HiveField(5)
  String monthYear; // e.g., "08-2025"

  @HiveField(6)
  String description;

  PaymentModel({
    required this.id,
    required this.tenantId,
    required this.datePaid,
    required this.amount,
    this.penalty = 0.0,
    required this.monthYear,
    required this.description,
  });
}
