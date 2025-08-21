import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:rentem/app/Data/Models/payment_model.dart';
import 'package:rentem/app/Data/Models/property_model.dart';
import 'package:rentem/app/Data/Models/settings_model.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/main.dart';

// Boxes
final propertiesBoxProvider = Provider<Box<PropertyModel>>((ref) => HiveService.propertiesBox);
final tenantsBoxProvider = Provider<Box<TenantModel>>((ref) => HiveService.tenantsBox);
final paymentsBoxProvider = Provider<Box<PaymentModel>>((ref) => HiveService.paymentsBox);
final settingsBoxProvider = Provider<Box<SettingsModel>>((ref) => HiveService.settingsBox);

// Lists (auto-updating via box.watch())
final propertiesProvider = StateNotifierProvider<CollectionNotifier<PropertyModel>, List<PropertyModel>>(
  (ref) => CollectionNotifier(box: ref.watch(propertiesBoxProvider)),
);

final tenantsProvider = StateNotifierProvider<CollectionNotifier<TenantModel>, List<TenantModel>>(
  (ref) => CollectionNotifier(box: ref.watch(tenantsBoxProvider)),
);

final paymentsProvider = StateNotifierProvider<CollectionNotifier<PaymentModel>, List<PaymentModel>>(
  (ref) => CollectionNotifier(box: ref.watch(paymentsBoxProvider)),
);

final settingsProvider = StateNotifierProvider<SingletonNotifier<SettingsModel>, SettingsModel?>((ref) {
  return SingletonNotifier(box: ref.watch(settingsBoxProvider));
});

class CollectionNotifier<T> extends StateNotifier<List<T>> {
  final Box<T> box;
  late final Stream<BoxEvent> _sub;

  CollectionNotifier({required this.box}) : super(box.values.toList()) {
    _sub = box.watch();
    _sub.listen((event) {
      state = box.values.toList();
    });
  }
}

class SingletonNotifier<T> extends StateNotifier<T?> {
  final Box<T> box;
  late final Stream<BoxEvent> _sub;

  SingletonNotifier({required this.box}) : super(box.values.isNotEmpty ? box.values.first : null) {
    _sub = box.watch();
    _sub.listen((event) {
      state = box.values.isNotEmpty ? box.values.first : null;
    });
  }

  Future<void> save(T value) async {
    if (box.isEmpty) {
      await box.add(value);
    } else {
      await box.putAt(0, value);
    }
  }
}
