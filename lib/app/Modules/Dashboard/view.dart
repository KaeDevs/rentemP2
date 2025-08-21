import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentem/app/Utils/font_styles.dart';
import 'package:rentem/app/Data/Providers/providers.dart';

import '../../Utils/tools.dart';

class DashBoardView extends ConsumerStatefulWidget {
  const DashBoardView({super.key});

  @override
  ConsumerState<DashBoardView> createState() => _DashboardScreenState();
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool large;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.canvasColor, size: large ? 36 : 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FontStyles.body.copyWith(
                    color: theme.canvasColor.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: FontStyles.heading.copyWith(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.bold,
                    fontSize: large ? 24 : 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardScreenState extends ConsumerState<DashBoardView>
    with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final properties = ref.watch(propertiesProvider);
    final tenants = ref.watch(tenantsProvider);
    final payments = ref.watch(paymentsProvider);
    final totalRevenue = payments.fold<double>(0.0, (sum, p) => sum + p.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: FontStyles.heading.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            
            children: [
              _fourButtons(theme: theme),
              const SizedBox(height: 8),
              // Summary cards
              // Row(
              //   children: [
              //     Expanded(
              //       child: _SummaryCard(
              //         title: 'Properties',
              //         value: properties.length.toString(),
              //         icon: Icons.home,
              //         color: theme.colorScheme.primary,
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: _SummaryCard(
              //         title: 'Tenants',
              //         value: tenants.length.toString(),
              //         icon: Icons.people_alt,
              //         color: theme.colorScheme.primary,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 16),
              _SummaryCard(
                title: 'Revenue',
                value: totalRevenue.toStringAsFixed(2),
                icon: Icons.currency_rupee,
                color: theme.colorScheme.primary,
                large: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () {},
  icon: Icon(Icons.add, color: theme.canvasColor,),
  label: Text('ADD', style: FontStyles.heading.copyWith(fontSize: 20,color: theme.canvasColor, fontWeight: FontWeight.bold),),
  backgroundColor: theme.colorScheme.primary,
),

    );
  }
}

class _fourButtons extends ConsumerWidget {
  const _fourButtons({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Row(
            children: [
              Expanded(
                child: NormalCard(
                  title: "Property",
                  icon: Icons.home,
                  color: theme.colorScheme.primary, 
                  onTap: () { context.pushNamed("propertyview");},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: NormalCard(
                  title: "Tenants",
                  icon: Icons.people_alt,
                  color: theme.colorScheme.primary, 
                  onTap: () { context.pushNamed("tenantsview");},
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Row(
            children: [
              Expanded(
                child: NormalCard(
                  title: "Payments",
                  icon: Icons.payment,
                  color: theme.colorScheme.primary, 
                  onTap: () { context.pushNamed("paymentsview");},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: NormalCard(
                  title: "Reports",
                  icon: Icons.analytics,
                  color: theme.colorScheme.primary, 
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0.0),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: NormalCard(
        //           title: "Settings",
        //           icon: Icons.settings,
        //           color: theme.colorScheme.primary, 
        //           onTap: () { context.pushNamed("settings");},
        //         ),
        //       ),
        //       const SizedBox(width: 16),
        //       Expanded(
        //         child: NormalCard(
        //           title: "Profile",
        //           icon: Icons.person,
        //           color: theme.colorScheme.primary, 
        //           onTap: () { context.pushNamed("profile");},
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class NormalCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const NormalCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.inversePrimary , 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: size.width * 0.1,
                    color: theme.canvasColor, 
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: FontStyles.heading.copyWith(
                      color: theme.canvasColor, 
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
