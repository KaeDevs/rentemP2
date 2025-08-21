import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/main.dart';

import '../../Utils/font_styles.dart';

class DetailedTenant extends ConsumerWidget {
  final TenantModel tenant;

  const DetailedTenant({super.key, required this.tenant});

  void _deleteTenant(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tenant'),
        content: const Text('Are you sure you want to delete this tenant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HiveService.tenantsBox.delete(tenant.id);
              context.pop();
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tenant.name,
          style: FontStyles.heading.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.pushNamed(
              'add_tenant',
              extra: tenant,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteTenant(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tenant.name,
                    style: FontStyles.heading.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Contact Info Card
            _InfoCard(
              theme: theme,
              title: 'Contact Information',
              items: [
                _InfoItem(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: tenant.contact,
                ),
                if (tenant.email != null && tenant.email!.isNotEmpty)
                  _InfoItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: tenant.email!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final List<_InfoItem> items;

  const _InfoCard({
    required this.theme,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FontStyles.heading.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(item.icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: FontStyles.body.copyWith(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        item.value,
                        style: FontStyles.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
