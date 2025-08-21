import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentem/app/Data/Models/profile_model.dart';
import 'package:rentem/main.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileModel?>((ref) {
  final box = HiveService.profileBox;
  return ProfileNotifier(initial: box.values.isNotEmpty ? box.values.first : null);
});

class ProfileNotifier extends StateNotifier<ProfileModel?> {
  ProfileNotifier({ProfileModel? initial}) : super(initial);

  Future<void> save(ProfileModel model) async {
    if (HiveService.profileBox.isEmpty) {
      await HiveService.profileBox.add(model);
    } else {
      await HiveService.profileBox.putAt(0, model);
    }
    state = model;
  }
}
