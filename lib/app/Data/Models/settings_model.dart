import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 5)
class SettingsModel extends HiveObject {
  @HiveField(0)
  double lateFeePerDay;

  @HiveField(1)
  int reminderDaysBeforeDue;

  @HiveField(2)
  bool enableNotifications;

  @HiveField(3)
  String currencySymbol;
  SettingsModel({
    required this.lateFeePerDay,
    required this.reminderDaysBeforeDue,
    this.enableNotifications = true,
    this.currencySymbol = '₹',
  });


}
