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
import '../../../../services/storage_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _uploadProfilePhoto(String email) async {
    final pickedFile = await StorageService.pickImage();
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = 'avatar_${email}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await StorageService.uploadImage(
        file: pickedFile,
        bucketPath: 'avatars/$fileName',
      );

      final profileAsync = ref.read(profileProvider);
      final profile = profileAsync.value;
      if (profile != null) {
        await ref.read(profileProvider.notifier).updateProfile(
              name: profile.name,
              email: profile.email,
              role: profile.role,
              phone: profile.phone,
              department: profile.department,
              photoUrl: url,
            );
      }
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Profile picture updated successfully!');
      }
    } catch (e) {
      debugPrint('[ProfileScreen] Error uploading photo: $e');
      if (mounted) {
        AppSnackbar.showError(context, 'Profile picture upload failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                            ? const Icon(Icons.person_rounded)
                            : null,
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _uploadProfilePhoto(profile.email),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
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
