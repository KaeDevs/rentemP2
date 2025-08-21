import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rentem/main.dart';
import 'package:rentem/app/Service/payment_service.dart';
import 'package:rentem/app/Service/tenant_service.dart';
import 'package:rentem/app/Service/property_service.dart';
import 'package:rentem/app/Data/Models/payment_model.dart';
import 'package:uuid/uuid.dart';
import '../../Data/Models/tenant_model.dart';
import '../../Utils/font_styles.dart';

class AddPayment extends ConsumerStatefulWidget {
  final PaymentModel? payment;
  const AddPayment({super.key, this.payment});

  @override
  ConsumerState<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends ConsumerState<AddPayment> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedMonthYear = DateFormat('MM-yyyy').format(DateTime.now());
  double _penalty = 0.0;
  String? _selectedTenantId;

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _amountController.text = widget.payment!.amount.toString();
      _descriptionController.text = widget.payment!.description;
      _selectedDate = widget.payment!.datePaid;
      _selectedMonthYear = widget.payment!.monthYear;
      _penalty = widget.payment!.penalty;
      _selectedTenantId = widget.payment!.tenantId;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedMonthYear = DateFormat('MM-yyyy').format(picked);
      });
    }
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTenantId == null || _selectedTenantId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a tenant')),
        );
        return;
      }
      final payment = PaymentModel(
        id: widget.payment?.id ?? const Uuid().v4(),
        tenantId: _selectedTenantId!,
        datePaid: _selectedDate ?? DateTime.now(),
        amount: double.parse(_amountController.text),
        penalty: _penalty,
        monthYear: _selectedMonthYear,
        description: _descriptionController.text,
      );

      if (widget.payment != null) {
        widget.payment!
          ..amount = payment.amount
          ..datePaid = payment.datePaid
          ..penalty = payment.penalty
          ..monthYear = payment.monthYear
          ..description = payment.description
          ..tenantId = _selectedTenantId!;
        widget.payment!.save();
      } else {
        PaymentService().add(payment);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get tenant name for display if editing existing payment
    final tenantModel = _selectedTenantId != null 
      ? TenantService().getById(_selectedTenantId!)
      : TenantModel(id: '', name: '', contact: '');
    final properties = HiveService.propertiesBox.values.toList();
    final linkedPropertyName = (() {
      if (tenantModel?.id?.isEmpty ?? true || tenantModel?.propertyId == null) return null;
      final prop = PropertyService().getById(tenantModel!.propertyId!);
      return prop?.name ?? prop?.address;
    })();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.payment != null ? 'Edit' : 'Add'} Payment',
          style: FontStyles.heading.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tenant Selector
              DropdownButtonFormField<String>(
                value: _selectedTenantId,
                decoration: InputDecoration(
                  labelText: 'Tenant *',
                  prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                items: [
                  for (final t in TenantService().getAll())
                    DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name),
                    )
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedTenantId = val;
                  });
                },
                validator: (val) => (val == null || val.isEmpty) ? 'Select tenant' : null,
              ),
              const SizedBox(height: 8),
              if (linkedPropertyName != null)
                Text('Property: $linkedPropertyName', style: FontStyles.body),
              const SizedBox(height: 16),
              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  prefixIcon: Icon(Icons.currency_rupee, color: theme.colorScheme.primary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date Picker
              ListTile(
                leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                title: Text(
                  _selectedDate != null 
                    ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                    : 'Select Date',
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description, color: theme.colorScheme.primary),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton(
                onPressed: _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.canvasColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Save Payment',
                  style: FontStyles.heading.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
