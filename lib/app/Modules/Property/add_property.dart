import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rentem/app/Data/Models/property_model.dart';
import 'package:rentem/main.dart'; // contains HiveService
import 'package:rentem/app/Data/Models/tenant_model.dart';
import 'package:rentem/app/Service/property_service.dart';

// State providers for form data
final propertyFormProvider =
    StateNotifierProvider<PropertyFormNotifier, PropertyFormState>((ref) {
      return PropertyFormNotifier();
    });

final currentStepProvider = StateProvider<int>((ref) => 0);

// Form state model
class PropertyFormState {
  final String name;
  final String address;
  final String rent;
  final String tenantId;
  final DateTime? dueDate;
  final DateTime? leaseStart;
  final DateTime? leaseEnd;
  final String? agreementPath;
  final List<String> pics;
  final bool isSubmitting;
  final String? errorMessage;

  const PropertyFormState({
    this.name = '',
    this.address = '',
    this.rent = '',
    this.tenantId = '',
    this.dueDate,
    this.leaseStart,
    this.leaseEnd,
    this.agreementPath,
    this.pics = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  PropertyFormState copyWith({
    String? name,
    String? address,
    String? rent,
    String? tenantId,
    DateTime? dueDate,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    String? agreementPath,
    List<String>? pics,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return PropertyFormState(
      name: name ?? this.name,
      address: address ?? this.address,
      rent: rent ?? this.rent,
      tenantId: tenantId ?? this.tenantId,
      dueDate: dueDate ?? this.dueDate,
      leaseStart: leaseStart ?? this.leaseStart,
      leaseEnd: leaseEnd ?? this.leaseEnd,
      agreementPath: agreementPath ?? this.agreementPath,
      pics: pics ?? this.pics,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isValid {
    return name.isNotEmpty &&
        address.isNotEmpty &&
        rent.isNotEmpty &&
        (double.tryParse(rent) ?? 0) > 0;
  }
}

// State notifier for form management
class PropertyFormNotifier extends StateNotifier<PropertyFormState> {
  PropertyFormNotifier() : super(const PropertyFormState());

  void updateName(String value) => state = state.copyWith(name: value);
  void updateAddress(String value) => state = state.copyWith(address: value);
  void updateRent(String value) => state = state.copyWith(rent: value);
  void updateTenantId(String value) => state = state.copyWith(tenantId: value);
  void updateDueDate(DateTime? date) => state = state.copyWith(dueDate: date);
  void updateLeaseStart(DateTime? date) =>
      state = state.copyWith(leaseStart: date);
  void updateLeaseEnd(DateTime? date) => state = state.copyWith(leaseEnd: date);
  void updateAgreementPath(String? path) =>
      state = state.copyWith(agreementPath: path);

  void addPicture(String path) {
    final newPics = List<String>.from(state.pics)..add(path);
    state = state.copyWith(pics: newPics);
  }

  void removePicture(int index) {
    final newPics = List<String>.from(state.pics)..removeAt(index);
    state = state.copyWith(pics: newPics);
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  Future<bool> submitProperty() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: "Please fill all required fields");
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final property = PropertyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: state.name,
        address: state.address,
        rentAmount: double.parse(state.rent),
        dueDate: state.dueDate ?? DateTime.now(),
        tenantId: state.tenantId,
        leaseStart: state.leaseStart ?? DateTime.now(),
        leaseEnd:
            state.leaseEnd ?? DateTime.now().add(const Duration(days: 365)),
        agreementFilePath: state.agreementPath,
        pics: state.pics,
      );

      await HiveService.propertiesBox.put(property.id, property);

      // Link tenant if selected
      if ((state.tenantId).isNotEmpty) {
        final tenant = HiveService.tenantsBox.values.firstWhere(
          (t) => t.id == state.tenantId,
          orElse: () => TenantModel(id: '', name: '', contact: ''),
        );
        if (tenant.id.isNotEmpty) {
          final saved = HiveService.propertiesBox.get(property.id) ?? property;
          await PropertyService().assignTenant(property: saved, tenant: tenant);
        }
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: "Failed to save property: ${e.toString()}",
      );
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

// Main widget
class AddProperty extends ConsumerStatefulWidget {
  const AddProperty({super.key});
  static const int totalSteps = 9;
  @override
  ConsumerState<AddProperty> createState() => _AddPropertyState();
}

class _AddPropertyState extends ConsumerState<AddProperty> {
  static const int totalSteps = 9;

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(currentStepProvider);
    final formState = ref.watch(propertyFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Property"), elevation: 0),
      body: Column(
        children: [
          // Progress indicator
          _ProgressIndicator(currentStep: currentStep),

          // Error display
          if (formState.errorMessage != null)
            _ErrorDisplay(message: formState.errorMessage!),

          // Form content
          Expanded(child: _FormContent(currentStep: currentStep)),

          // Navigation buttons
          _NavigationButtons(
            currentStep: currentStep,
            isSubmitting: formState.isSubmitting,
            canProceed: _canProceedFromStep(currentStep, formState),
          ),
        ],
      ),
    );
  }

  bool _canProceedFromStep(int step, PropertyFormState formState) {
    switch (step) {
      case 1:
        return formState.name.isNotEmpty;
      case 2:
        return formState.address.isNotEmpty;
      case 3:
        return formState.rent.isNotEmpty &&
            (double.tryParse(formState.rent) ?? 0) > 0;
      case 8:
        return formState.isValid; // Final step
      default:
        return true;
    }
  }
}

// Progress indicator widget
class _ProgressIndicator extends StatelessWidget {
  final int currentStep;

  const _ProgressIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentStep + 1) / AddProperty.totalSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Step ${currentStep + 1} of ${AddProperty.totalSteps}",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${(progress * 100).round()}%",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// Error display widget
class _ErrorDisplay extends ConsumerWidget {
  final String message;

  const _ErrorDisplay({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(propertyFormProvider.notifier).clearError(),
            icon: const Icon(Icons.close, size: 16),
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }
}

// Form content widget
class _FormContent extends StatelessWidget {
  final int currentStep;

  const _FormContent({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: _buildStepWidget(currentStep),
      ),
    );
  }

  Widget _buildStepWidget(int step) {
    switch (step) {
      case 0:
        return const PicturesStep(key: ValueKey(0));
      case 1:
        return const PropertyNameStep(key: ValueKey(1));
      case 2:
        return const AddressStep(key: ValueKey(2));
      case 3:
        return const RentAmountStep(key: ValueKey(3));
      case 4:
        return const DueDateStep(key: ValueKey(4));
      case 5:
        return const TenantIdStep(key: ValueKey(5));
      case 6:
        return const LeaseStartStep(key: ValueKey(6));
      case 7:
        return const LeaseEndStep(key: ValueKey(7));
      case 8:
        return const AgreementStep(key: ValueKey(8));
      default:
        return const SizedBox.shrink();
    }
  }
}

// Navigation buttons widget
class _NavigationButtons extends ConsumerWidget {
  final int currentStep;
  final bool isSubmitting;
  final bool canProceed;

  const _NavigationButtons({
    required this.currentStep,
    required this.isSubmitting,
    required this.canProceed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLastStep = currentStep == AddProperty.totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () {
                        ref.read(currentStepProvider.notifier).state =
                            currentStep - 1;
                      },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: currentStep > 0 ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: (canProceed && !isSubmitting)
                  ? () async {
                      if (isLastStep) {
                        final success = await ref
                            .read(propertyFormProvider.notifier)
                            .submitProperty();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Property saved successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } else {
                        ref.read(currentStepProvider.notifier).state =
                            currentStep + 1;
                      }
                    }
                  : null,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isLastStep ? Icons.check : Icons.arrow_forward),
              label: Text(
                isSubmitting ? "Saving..." : (isLastStep ? "Submit" : "Next"),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Individual step widgets
class PicturesStep extends ConsumerWidget {
  const PicturesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pics = ref.watch(propertyFormProvider.select((state) => state.pics));
    final notifier = ref.read(propertyFormProvider.notifier);

    return _StepContainer(
      title: "Add Property Pictures",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pics.isEmpty)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No pictures added",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(pics[index]),
                          width: 160,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 160,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => notifier.removePicture(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          _AddImageButtons(notifier: notifier),
        ],
      ),
    );
  }
}

class _AddImageButtons extends StatelessWidget {
  final PropertyFormNotifier notifier;

  const _AddImageButtons({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text("Gallery"),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        notifier.addPicture(pickedFile.path);
      }
    } catch (e) {
      // Handle error appropriately in your app
      debugPrint('Error picking image: $e');
    }
  }
}

class PropertyNameStep extends ConsumerStatefulWidget {
  const PropertyNameStep({super.key});

  @override
  ConsumerState<PropertyNameStep> createState() => _PropertyNameStepState();
}

class _PropertyNameStepState extends ConsumerState<PropertyNameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(propertyFormProvider).name,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      title: "Property Name",
      child: _FormTextField(
        controller: _controller,
        hint: "Enter property name",
        onChanged: (value) =>
            ref.read(propertyFormProvider.notifier).updateName(value),
        validator: (value) =>
            value?.isEmpty == true ? "Property name is required" : null,
      ),
    );
  }
}

class AddressStep extends ConsumerStatefulWidget {
  const AddressStep({super.key});

  @override
  ConsumerState<AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends ConsumerState<AddressStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(propertyFormProvider).address,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      title: "Property Address",
      child: _FormTextField(
        controller: _controller,
        hint: "Enter complete address",
        maxLines: 3,
        onChanged: (value) =>
            ref.read(propertyFormProvider.notifier).updateAddress(value),
        validator: (value) =>
            value?.isEmpty == true ? "Address is required" : null,
      ),
    );
  }
}

class RentAmountStep extends ConsumerStatefulWidget {
  const RentAmountStep({super.key});

  @override
  ConsumerState<RentAmountStep> createState() => _RentAmountStepState();
}

class _RentAmountStepState extends ConsumerState<RentAmountStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(propertyFormProvider).rent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      title: "Monthly Rent Amount",
      child: _FormTextField(
        controller: _controller,
        hint: "Enter monthly rent",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        prefixText: "₹ ",
        onChanged: (value) =>
            ref.read(propertyFormProvider.notifier).updateRent(value),
        validator: (value) {
          if (value?.isEmpty == true) return "Rent amount is required";
          final amount = double.tryParse(value!);
          if (amount == null || amount <= 0) return "Enter a valid amount";
          return null;
        },
      ),
    );
  }
}

class DueDateStep extends ConsumerWidget {
  const DueDateStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDate = ref.watch(
      propertyFormProvider.select((state) => state.dueDate),
    );

    return _StepContainer(
      title: "Rent Due Date",
      child: _DateSelector(
        selectedDate: dueDate,
        hint: "Select due date",
        onDateSelected: (date) =>
            ref.read(propertyFormProvider.notifier).updateDueDate(date),
      ),
    );
  }
}

class TenantIdStep extends ConsumerStatefulWidget {
  const TenantIdStep({super.key});

  @override
  ConsumerState<TenantIdStep> createState() => _TenantIdStepState();
}

class _TenantIdStepState extends ConsumerState<TenantIdStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(propertyFormProvider).tenantId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tenants = HiveService.tenantsBox.values.toList();
    final selectedId = ref.watch(propertyFormProvider.select((s) => s.tenantId));

    return _StepContainer(
      title: "Assign Tenant (optional)",
      child: DropdownButtonFormField<String>(
        value: selectedId.isEmpty ? '' : selectedId,
        items: [
          const DropdownMenuItem<String>(value: '', child: Text('No Tenant')),
          for (final t in tenants)
            DropdownMenuItem<String>(
              value: t.id,
              child: Text(t.name),
            ),
        ],
        onChanged: (val) {
          final id = (val ?? '').isEmpty ? '' : val!;
          _controller.text = id;
          ref.read(propertyFormProvider.notifier).updateTenantId(id);
        },
        decoration: InputDecoration(
          hintText: 'Select a tenant (optional)',
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class LeaseStartStep extends ConsumerWidget {
  const LeaseStartStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaseStart = ref.watch(
      propertyFormProvider.select((state) => state.leaseStart),
    );

    return _StepContainer(
      title: "Lease Start Date",
      child: _DateSelector(
        selectedDate: leaseStart,
        hint: "Select lease start date",
        onDateSelected: (date) =>
            ref.read(propertyFormProvider.notifier).updateLeaseStart(date),
      ),
    );
  }
}

class LeaseEndStep extends ConsumerWidget {
  const LeaseEndStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaseEnd = ref.watch(
      propertyFormProvider.select((state) => state.leaseEnd),
    );

    return _StepContainer(
      title: "Lease End Date",
      child: _DateSelector(
        selectedDate: leaseEnd,
        hint: "Select lease end date",
        onDateSelected: (date) =>
            ref.read(propertyFormProvider.notifier).updateLeaseEnd(date),
      ),
    );
  }
}

class AgreementStep extends ConsumerWidget {
  const AgreementStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementPath = ref.watch(
      propertyFormProvider.select((state) => state.agreementPath),
    );
    final notifier = ref.read(propertyFormProvider.notifier);

    return _StepContainer(
      title: "Upload Agreement Document",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (agreementPath != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Selected: ${agreementPath.split('/').last}",
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => notifier.updateAgreementPath(null),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                    allowMultiple: false,
                  );

                  if (result != null && result.files.single.path != null) {
                    notifier.updateAgreementPath(result.files.single.path);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error selecting file: $e")),
                    );
                  }
                }
              },
              icon: const Icon(Icons.upload_file),
              label: Text(
                agreementPath == null ? "Upload Document" : "Change Document",
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Supported formats: PDF, DOC, DOCX (Optional)",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Reusable components
class _StepContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _StepContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        child,
      ],
    );
  }
}

class _FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _FormTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixText,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final String hint;
  final ValueChanged<DateTime> onDateSelected;

  const _DateSelector({
    required this.selectedDate,
    required this.hint,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat.yMMMMd().format(selectedDate!)
                    : hint,
                style: TextStyle(
                  color: selectedDate != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }
}
