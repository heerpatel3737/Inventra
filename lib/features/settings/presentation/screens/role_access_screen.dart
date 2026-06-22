import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/settings_providers.dart';

class RoleAccessScreen extends ConsumerWidget {
  const RoleAccessScreen({super.key});

  static const _allPermissions = [
    'Dashboard',
    'Products',
    'Sales',
    'Purchases',
    'Reports',
    'Analytics',
    'Settings',
    'Scanner',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);
    final refresh = ref.read(rolesRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.roleAccess,
      title: 'Role Access',
      header: const EditorialHeader(
        eyebrow: 'Access Governance',
        title: 'Permission Matrix',
        subtitle: 'Assign capabilities with role-specific precision and enterprise-grade governance.',
      ),
      children: [
        rolesAsync.when(
          loading: () => const AppLoadingView(message: 'Loading roles...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load roles.\n$error',
            onRetry: refresh,
          ),
          data: (roles) => Column(
            children: roles.map((role) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(_roleIcon(role.id)),
                          title: Text(role.name),
                          subtitle: Text(role.description),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allPermissions.map((permission) {
                            final enabled = role.permissions.contains(permission);
                            return FilterChip(
                              label: Text(permission),
                              selected: enabled,
                              onSelected: (_) => ref.read(rolesProvider.notifier).togglePermission(role.id, permission),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _roleIcon(String roleId) {
    switch (roleId) {
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'manager':
        return Icons.manage_accounts_outlined;
      default:
        return Icons.store_outlined;
    }
  }
}
