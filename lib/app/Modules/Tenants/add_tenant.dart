import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:rentem/main.dart';
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/app/Data/Models/property_model.dart';
import 'package:rentem/app/Service/property_service.dart';
import 'package:rentem/app/Service/tenant_service.dart';

import '../../Utils/font_styles.dart';

class AddTenant extends ConsumerStatefulWidget {
  final TenantModel? tenant;
  const AddTenant({super.key, this.tenant});

  @override
  ConsumerState<AddTenant> createState() => _AddTenantState();
}

class _AddTenantState extends ConsumerState<AddTenant> {
  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();
  late final TenantModel? _existingTenant = widget.tenant;
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedPropertyId; // optional property assignment

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveTenant() {
    if (_formKey.currentState!.validate()) {
      final tenant = TenantModel(
        id: _existingTenant?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        contact: _contactController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      );

      if (_existingTenant != null) {
        _existingTenant!
          ..name = _nameController.text.trim()
          ..contact = _contactController.text.trim()
          ..email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
        _existingTenant!.save();
        // handle assignment updates for existing tenant
        final tenantService = TenantService();
        if (_selectedPropertyId == null || _selectedPropertyId!.isEmpty) {
          // unassign if previously assigned
          if (_existingTenant!.propertyId != null) {
            final property = PropertyService().getById(_existingTenant!.propertyId!);
            if (property != null) {
              PropertyService().unassignTenant(property: property);
            }
          }
        } else {
          final property = PropertyService().getById(_selectedPropertyId!);
          if (property != null) {
            PropertyService().assignTenant(property: property, tenant: _existingTenant!);
          }
        }
      } else {
        HiveService.tenantsBox.add(tenant);
        // if assignment selected, link it
        if (_selectedPropertyId != null && _selectedPropertyId!.isNotEmpty) {
          final property = HiveService.propertiesBox.values.firstWhere(
            (p) => p.id == _selectedPropertyId,
            orElse: () => PropertyModel(id: '', address: '', rentAmount: 0, dueDate: DateTime.now()),
          );
          if (property.id.isNotEmpty) {
            PropertyService().assignTenant(property: property, tenant: tenant);
          }
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tenant ${_existingTenant != null ? 'updated' : 'added'} successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final properties = HiveService.propertiesBox.values.toList();
    final availableProps = properties.where((p) {
  final isVacant = !p.isOccupied && p.tenantId == null;
  final isCurrentAssignment = _existingTenant?.propertyId == p.id;
  return isVacant || isCurrentAssignment;
}).toList();

    // Preselect currently assigned property when editing
    _selectedPropertyId ??= _existingTenant?.propertyId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Tenant',
          style: FontStyles.heading.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface.withOpacity(0.9),
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    labelStyle: FontStyles.body.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: FontStyles.body,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter tenant name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Contact Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface.withOpacity(0.9),
                ),
                child: TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Contact Number *',
                    labelStyle: FontStyles.body.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: FontStyles.body,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter contact number';
                    }
                    if (value.trim().length < 10) {
                      return 'Please enter a valid contact number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface.withOpacity(0.9),
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    labelStyle: FontStyles.body.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: FontStyles.body,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Property Assignment (optional)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface.withOpacity(0.9),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedPropertyId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('No Property'),
                    ),
                    for (final p in availableProps)
                      DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name ?? p.address),
                      ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedPropertyId = (val ?? '').isEmpty ? null : val;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Assign Property (optional)',
                    labelStyle: FontStyles.body.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.home_work_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveTenant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.canvasColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Tenant',
                  style: FontStyles.heading.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
