import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_sizes.dart';
import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import '../../providers/auth_provider.dart';

class LuxurySidebar extends ConsumerWidget {
  final String currentRoute;
  const LuxurySidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
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

    final groups = {
      'Operations': [
        (AppRoutes.dashboard, 'Dashboard', Icons.dashboard_outlined),
        (AppRoutes.products, 'Products', Icons.inventory_2_outlined),
        (AppRoutes.categories, 'Categories', Icons.category_outlined),
        (AppRoutes.suppliers, 'Suppliers', Icons.groups_outlined),
        (AppRoutes.sales, 'Sales', Icons.show_chart_outlined),
        (AppRoutes.purchases, 'Purchases', Icons.shopping_bag_outlined),
      ],
      'Insights': [
        (AppRoutes.analytics, 'Analytics', Icons.auto_graph_outlined),
        (AppRoutes.reports, 'Reports', Icons.insert_chart_outlined),
        (AppRoutes.notifications, 'Notifications', Icons.notifications_none_rounded),
      ],
      'System': [
        (AppRoutes.settings, 'Settings', Icons.tune_rounded),
        (AppRoutes.profile, 'Profile', Icons.person_outline_rounded),
        (AppRoutes.roleAccess, 'Role Access', Icons.shield_outlined),
        (AppRoutes.inventoryAlerts, 'Stock Alerts', Icons.warning_amber_outlined),
        (AppRoutes.scanner, 'Scanner', Icons.qr_code_scanner_outlined),
        (AppRoutes.offlineSync, 'Offline Sync', Icons.sync_rounded),
      ]
    };

    return Drawer(
      width: AppSizes.sidebarWidth,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Icon(Icons.person, color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: groups.entries.expand((entry) {
                    return [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        child: Text(entry.key.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
                      ),
                      ...entry.value.map((e) {
                        final badgeCount = e.$1 == AppRoutes.notifications ? unreadCount : 0;
                        return _item(context, e.$1, e.$2, e.$3, badgeCount: badgeCount);
                      }),
                    ];
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Logout'),
                  onTap: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.authGate,
                        (_) => false,
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String route,
    String title,
    IconData icon, {
    int badgeCount = 0,
  }) {
    final active = route == currentRoute;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: active ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          if (!active) Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}
