import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/settings_providers.dart';
import '../widgets/profile_edit_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final refresh = ref.read(profileRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.profile,
      title: 'Profile',
      header: const EditorialHeader(
        eyebrow: 'Identity Layer',
        title: 'Professional Profile',
        subtitle: 'Personal identity, role context, and access posture in one curated panel.',
      ),
      children: [
        profileAsync.when(
          loading: () => const AppLoadingView(message: 'Loading profile...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load profile.\n$error',
            onRetry: refresh,
          ),
          data: (profile) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(profile.name),
                  subtitle: Text('${profile.email}\n${profile.role}'),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(label: 'Phone', value: profile.phone),
                      const Divider(height: 20),
                      _InfoRow(label: 'Department', value: profile.department),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LuxuryButton(
                label: 'Edit Profile',
                icon: Icons.edit_rounded,
                onPressed: () => openProfileEditDialog(
                  context,
                  profile: profile,
                  onSave: ({
                    required name,
                    required email,
                    required role,
                    required phone,
                    required department,
                  }) {
                    ref.read(profileProvider.notifier).updateProfile(
                          name: name,
                          email: email,
                          role: role,
                          phone: phone,
                          department: department,
                        );
                    AppSnackbar.showSuccess(context, 'Profile Updated');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
        Expanded(
          flex: 2,
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
