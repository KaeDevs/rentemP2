import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:rentem/app/Data/Models/property_model.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/app/Modules/Property/add_property.dart';
import 'package:rentem/app/Service/tenant_service.dart';
import 'package:rentem/app/Modules/Tenants/add_tenant.dart';

class DetailedProperty extends ConsumerWidget {
  final PropertyModel property;
  final TenantService tenantService = TenantService();

  DetailedProperty({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name ?? "Property Details"),
        elevation: 0,
        backgroundColor: theme.colorScheme.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddProperty(
                  existingProperty: property,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Image
            property.pics != null && property.pics!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      property.pics!.first,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: theme.colorScheme.primary.withOpacity(0.15),
                    ),
                    child: const Icon(Icons.home, size: 80, color: Colors.grey),
                  ),

            const SizedBox(height: 16),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name ?? "Unnamed Property",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.address,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rent + Due Date
                  _buildDetailCard(
                    context,
                    icon: Icons.attach_money,
                    title: "Rent Amount",
                    value: "₹${property.rentAmount.toStringAsFixed(0)} / month",
                  ),
                  _buildDetailCard(
                    context,
                    icon: Icons.calendar_today,
                    title: "Rent Due Date",
                    value:
                        "${property.dueDate.day}/${property.dueDate.month}/${property.dueDate.year}",
                  ),

                  // Lease Period
                  _buildDetailCard(
                    context,
                    icon: Icons.timelapse,
                    title: "Lease Period",
                    value:
                        "${property.leaseStart!.day}/${property.leaseStart!.month}/${property.leaseStart!.year} → ${property.leaseEnd!.day}/${property.leaseEnd!.month}/${property.leaseEnd!.year}",
                  ),

                  // Agreement
                  if (property.agreementFilePath != null)
                    _buildDetailCard(
                      context,
                      icon: Icons.description,
                      title: "Agreement File",
                      value: property.agreementFilePath!,
                    ),

                  const SizedBox(height: 24),

                  // Tenant Management Section
                  if (property.tenantId != null)
                    _buildTenantCard(context, tenantService.getById(property.tenantId!)!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantCard(BuildContext context, TenantModel tenant) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 28, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assigned Tenant",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tenant.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20),
                      onPressed: () => _handleTenantEdit(context, tenant),
                    ),
                    IconButton(
                      icon: Icon(Icons.person_remove, size: 20),
                      onPressed: _handleUnassignTenant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTenantEdit(BuildContext context, TenantModel tenant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTenant(tenant: tenant),
      ),
    );
  }

  void _handleUnassignTenant() {
    property.tenantId = null;
    property.isOccupied = false;
    property.save();
  }

  Widget _buildDetailCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String value}) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
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
