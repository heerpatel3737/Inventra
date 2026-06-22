import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/providers/theme_mode_provider.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return LuxuryScaffold(
      route: AppRoutes.settings,
      title: 'Settings Atelier',
      header: const EditorialHeader(
        eyebrow: 'Configuration',
        title: 'Refined Workspace Preferences',
        subtitle: 'Manage account integrity, appearance language, and operational permissions.',
      ),
      children: [
        SettingsTile(
          icon: Icons.person_outline,
          title: 'Profile Details',
          subtitle: 'Name, photo, and business identity preferences',
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        ),
        const SizedBox(height: 10),
        SettingsTile(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          subtitle: 'Switch between light, dark, and system themes',
          trailing: DropdownButton<ThemeMode>(
            value: themeMode,
            underline: const SizedBox.shrink(),
            dropdownColor: Theme.of(context).colorScheme.surface,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onSurface),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).state = value;
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        const SettingsTile(
          icon: Icons.security_rounded,
          title: 'Security Controls',
          subtitle: 'Sessions, access logs, and role policies',
        ),
        const SizedBox(height: 10),
        SettingsTile(
          icon: Icons.shield_outlined,
          title: 'Role Access',
          subtitle: 'Control module-level access rules',
          onTap: () => Navigator.pushNamed(context, AppRoutes.roleAccess),
        ),
        const SizedBox(height: 10),
        SettingsTile(
          icon: Icons.sync_rounded,
          title: 'Offline Sync',
          subtitle: 'Queue health and conflict resolution status',
          onTap: () => Navigator.pushNamed(context, AppRoutes.offlineSync),
        ),
      ],
    );
  }
}
