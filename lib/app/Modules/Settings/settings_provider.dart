import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentem/app/Data/Models/settings_model.dart';
import 'package:rentem/main.dart';

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsModel?>((ref) {
  final box = HiveService.settingsBox;
  return SettingsNotifier(initial: box.values.isNotEmpty ? box.values.first : null);
});

class SettingsNotifier extends StateNotifier<SettingsModel?> {
  SettingsNotifier({SettingsModel? initial}) : super(initial);

  Future<void> save(SettingsModel model) async {
    if (HiveService.settingsBox.isEmpty) {
      await HiveService.settingsBox.add(model);
    } else {
      await HiveService.settingsBox.putAt(0, model);
    }
    state = model;
  }
}
