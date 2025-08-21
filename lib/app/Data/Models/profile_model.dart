import 'package:hive/hive.dart';

part 'profile_model.g.dart';


@HiveType(typeId: 1)
class ProfileModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? contactNumber;

  @HiveField(3)
  String? email;

  ProfileModel({
    required this.id,
    required this.name,
    this.contactNumber,
    this.email,
  });
}
