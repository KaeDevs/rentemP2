import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentem/app/Data/Models/profile_model.dart';
import 'package:rentem/app/Modules/Profile/provider/profile_provider.dart';
import 'package:rentem/app/Utils/font_styles.dart';

class EditProfileView extends ConsumerStatefulWidget {
  final ProfileModel? profile;
  const EditProfileView({super.key, this.profile});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _emailController.text = widget.profile!.email!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: FontStyles.heading.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // final model = ProfileModel(id: ,name: _nameController.text.trim(), email: _emailController.text.trim());
                // await ref.read(profileProvider.notifier).save(model);
                // if (!mounted) return;
                // context.pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
