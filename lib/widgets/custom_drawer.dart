import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_sizes.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import '../providers/auth_provider.dart';

class CustomDrawer extends ConsumerWidget {
  final String currentRoute;
  const CustomDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(profileProvider);

    // Extract Firebase Auth user data
    final user = authState.valueOrNull;
    final photoUrl = user?.photoURL;

    // Prefer profile name/role from persisted profile, fallback to Firebase Auth
    final profileData = profileAsync.valueOrNull;
    final displayName = (profileData != null && profileData.name.isNotEmpty)
        ? profileData.name
        : (user?.displayName?.isNotEmpty == true)
            ? user!.displayName!
            : (user?.email?.split('@').first ?? 'User');
    final subtitle = (profileData != null && profileData.role.isNotEmpty)
        ? profileData.role
        : (user?.email ?? '');

    final coreItems = <({String route, String label, IconData icon})>[
      (route: AppRoutes.dashboard, label: 'Overview', icon: Icons.space_dashboard_rounded),
      (route: AppRoutes.products, label: 'Products', icon: Icons.inventory_2_rounded),
      (route: AppRoutes.categories, label: 'Categories', icon: Icons.category_rounded),
      (route: AppRoutes.suppliers, label: 'Suppliers', icon: Icons.groups_2_rounded),
      (route: AppRoutes.sales, label: 'Sales', icon: Icons.point_of_sale_rounded),
      (route: AppRoutes.purchases, label: 'Purchases', icon: Icons.shopping_cart_rounded),
      (route: AppRoutes.reports, label: 'Reports', icon: Icons.description_rounded),
      (route: AppRoutes.analytics, label: 'Analytics', icon: Icons.analytics_rounded),
    ];

    final systemItems = <({String route, String label, IconData icon})>[
      (route: AppRoutes.notifications, label: 'Notifications', icon: Icons.notifications_active_rounded),
      (route: AppRoutes.settings, label: 'Settings', icon: Icons.settings_rounded),
      (route: AppRoutes.profile, label: 'Profile', icon: Icons.person_rounded),
      (route: AppRoutes.roleAccess, label: 'Role Access', icon: Icons.admin_panel_settings_rounded),
      (route: AppRoutes.inventoryAlerts, label: 'Stock Alerts', icon: Icons.warning_amber_rounded),
      (route: AppRoutes.scanner, label: 'Barcode Scanner', icon: Icons.qr_code_scanner_rounded),
      (route: AppRoutes.offlineSync, label: 'Offline Sync', icon: Icons.sync_rounded),
    ];

    return Drawer(
      width: AppSizes.drawerWidth,
      child: Container(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.gradientIndigo),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person_rounded, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  children: [
                    _groupTitle(context, 'Management'),
                    ...coreItems.map((item) => _item(context, item.route, item.label, item.icon)),
                    const SizedBox(height: 8),
                    _groupTitle(context, 'System'),
                    ...systemItems.map((item) => _item(context, item.route, item.label, item.icon)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
                  title: Text('Log out', style: TextStyle(color: colorScheme.onSurface)),
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _item(BuildContext context, String route, String label, IconData icon) {
    final active = currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: active,
        selectedTileColor: colorScheme.secondaryContainer.withValues(alpha: 0.35),
        leading: Icon(
          icon,
          color: active ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.68),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (!active) Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}
