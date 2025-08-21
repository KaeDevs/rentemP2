import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rentem/app/Route/app_pages.dart';
import 'package:rentem/app/Theme/app_theme.dart';
import 'package:rentem/app/Data/Models/property_model.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/app/Data/Models/payment_model.dart';
import 'package:rentem/app/Data/Models/settings_model.dart';

import 'app/Data/Models/profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( 
  ); 
  await HiveService.init();

  runApp(
    const ProviderScope(child: MyApp()),
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: AppTheme().darkTheme.colorScheme,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,   );
  }
}


class HiveService {
  static const String _profileBoxName = 'profile';
  static const String _propertiesBoxName = 'properties';
  static const String _tenantsBoxName = 'tenants';
  static const String _paymentsBoxName = 'payments';
  static const String _settingsBoxName = 'settings';
  
  static late final Box<ProfileModel> profileBox;
  static late final Box<PropertyModel> propertiesBox;
  static late final Box<TenantModel> tenantsBox;
  static late final Box<PaymentModel> paymentsBox;
  static late final Box<SettingsModel> settingsBox;
  
  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ProfileModelAdapter());
    Hive.registerAdapter(PropertyModelAdapter());
    Hive.registerAdapter(TenantModelAdapter());
    Hive.registerAdapter(PaymentModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    
    // Open boxes
    profileBox = await Hive.openBox<ProfileModel>(_profileBoxName);
    propertiesBox = await Hive.openBox<PropertyModel>(_propertiesBoxName);
    tenantsBox = await Hive.openBox<TenantModel>(_tenantsBoxName);
    paymentsBox = await Hive.openBox<PaymentModel>(_paymentsBoxName);
    settingsBox = await Hive.openBox<SettingsModel>(_settingsBoxName);
  }
  
  // Get profile box
  
  // Get properties box
  
  // Get tenants box
  
  // Get payments box
  
  // Get settings box
  
  // Close all boxes
  static Future<void> close() async {
    await profileBox.close();
    await propertiesBox.close();
    await tenantsBox.close();
    await paymentsBox.close();
    await settingsBox.close();
  }
}
