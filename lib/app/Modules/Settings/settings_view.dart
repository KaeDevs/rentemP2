import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentem/app/Data/Models/settings_model.dart';
import 'package:rentem/app/Modules/Settings/settings_provider.dart';
import 'package:rentem/app/Utils/font_styles.dart';
import 'package:rentem/main.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final _currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsNotifierProvider);
    _currencyController.text = s?.currencySymbol ?? '₹';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: FontStyles.heading.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _currencyController,
              decoration: const InputDecoration(labelText: 'Currency Symbol'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final currentSettings = ref.read(settingsNotifierProvider) ?? 
                  SettingsModel(
                    currencySymbol: '₹',
                    lateFeePerDay: 0.0,
                    reminderDaysBeforeDue: 3
                  );
                final model = SettingsModel(
                  currencySymbol: _currencyController.text.trim().isNotEmpty 
                      ? _currencyController.text.trim()
                      : '₹',
                  lateFeePerDay: currentSettings.lateFeePerDay,
                  reminderDaysBeforeDue: currentSettings.reminderDaysBeforeDue,
                );
                await ref.read(settingsNotifierProvider.notifier).save(model);
                if (!mounted) return; 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
