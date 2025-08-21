import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentem/app/Modules/Profile/provider/profile_provider.dart';
import 'package:rentem/app/Utils/font_styles.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: FontStyles.heading.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${profile?.name ?? '-'}', style: FontStyles.subheading),
            const SizedBox(height: 8),
            Text('Email: ${profile?.email ?? '-'}', style: FontStyles.body),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.pushNamed('edit_profile', extra: profile),
              child: const Text('Edit Profile'),
            )
          ],
        ),
      ),
    );
  }
}
