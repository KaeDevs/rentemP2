import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentem/app/Data/Models/property_model.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/app/Modules/Tenants/add_tenant.dart';
import 'package:rentem/app/Modules/Tenants/detailed_tenant.dart';
import 'package:rentem/app/Modules/Login/onBoardView.dart';
import 'package:rentem/app/Modules/Property/add_property.dart';
import 'package:rentem/app/Modules/Property/detailed_property.dart';
import 'package:rentem/app/Modules/Tenants/view.dart';
import 'package:rentem/app/Data/Models/payment_model.dart';
import 'package:rentem/app/Modules/Payments/view.dart';
import 'package:rentem/app/Modules/Payments/add_payment.dart';
import 'package:rentem/app/Modules/Payments/detailed_payment.dart';
import 'package:rentem/app/Modules/Settings/settings_view.dart';
import 'package:rentem/app/Modules/Profile/profile_view.dart';
import 'package:rentem/app/Modules/Profile/edit_profile.dart';

import '../Data/Models/profile_model.dart';
import '../Modules/Dashboard/view.dart';
import '../Modules/Login/view.dart';
import '../Modules/Property/view.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/onboard',
        name: 'onboard',
        builder: (context, state) => const OnBoardView(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashBoardView(),
      ),
      GoRoute(
        path: '/propertyview',
        name: 'propertyview',
        builder: (context, state) => const PropertyView(),
      ),
      GoRoute(
        path: '/addproperty',
        name: 'addproperty',
        builder: (context, state) => const AddProperty(),
      ),
     GoRoute(
  path: '/propertydetails',
  name: 'propertydetails',
  builder: (context, state) {
    final property = state.extra as PropertyModel;
    return DetailedProperty(property: property);
  },
),
GoRoute(
  path: '/add_tenant',
  name: 'add_tenant',
  pageBuilder: (context, state) => MaterialPage(
    child: AddTenant(tenant: state.extra as TenantModel?),
  ),
),

GoRoute(
  path: '/tenant_details',
  name: 'tenant_details',
  pageBuilder: (context, state) => MaterialPage(
    child: DetailedTenant(tenant: state.extra as TenantModel),
  ),
),
GoRoute(
  path: '/tenantsview',
  name: 'tenantsview',
      pageBuilder: (context, state) => MaterialPage(
        child: TenantsView(),
      ),
    ),
    GoRoute(
      path: '/payments',
      name: 'payments',
      pageBuilder: (context, state) => MaterialPage(
        child: PaymentsView(),
      ),
    ),
    GoRoute(
      path: '/addpayment',
      name: 'addpayment',
      pageBuilder: (context, state) => MaterialPage(
        child: AddPayment(payment: state.extra as PaymentModel?),
      ),
    ),
    GoRoute(
      path: '/paymentdetails',
      name: 'paymentdetails',
      pageBuilder: (context, state) => MaterialPage(
        child: DetailedPayment(payment: state.extra as PaymentModel),
      ),
    ),
    GoRoute(
      path: '/paymentsview',
      name: 'paymentsview',
      pageBuilder: (context, state) => MaterialPage(
        child: PaymentsView(),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => MaterialPage(
        child: SettingsView(),
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => MaterialPage(
        child: ProfileView(),
      ),
    ),
    GoRoute(
      path: '/edit_profile',
      name: 'edit_profile',
      pageBuilder: (context, state) => MaterialPage(
        child: EditProfileView(profile: state.extra as ProfileModel?),
      ),
    ),
    
    ],
  );
});
