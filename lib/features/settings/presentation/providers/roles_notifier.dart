import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/role_model.dart';
import '../../data/settings_repository.dart';

class RolesNotifier extends StateNotifier<AsyncValue<List<RoleModel>>> {
  RolesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRoles();
  }

  final SettingsRepository _repository;

  static const _seedRoles = [
    RoleModel(
      id: 'admin',
      name: 'Administrator',
      description: 'Full access to all system modules and user management',
      permissions: [
        'Dashboard', 'Products', 'Categories', 'Suppliers',
        'Sales', 'Purchases', 'Reports', 'Analytics',
        'Settings', 'Scanner', 'Notifications', 'Role Management',
      ],
    ),
    RoleModel(
      id: 'manager',
      name: 'Manager',
      description: 'Operational management of inventory and sales',
      permissions: [
        'Dashboard', 'Products', 'Categories', 'Suppliers',
        'Sales', 'Purchases', 'Reports', 'Analytics',
      ],
    ),
    RoleModel(
      id: 'staff',
      name: 'Staff',
      description: 'Basic access for day-to-day operations',
      permissions: [
        'Dashboard', 'Products', 'Sales',
      ],
    ),
  ];

  Future<void> loadRoles() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      var roles = await _repository.fetchRoles();

      // Seed default roles if none exist
      if (roles.isEmpty) {
        for (final seed in _seedRoles) {
          await _repository.updateRole(seed);
        }
        roles = await _repository.fetchRoles();
      }

      return roles;
    });
  }

  /// Toggle a permission for a role and persist to SQLite.
  Future<void> togglePermission(String roleId, String permission) async {
    final current = state.value;
    if (current == null) return;

    final updated = [
      for (final role in current)
        if (role.id == roleId)
          role.copyWith(
            permissions: role.permissions.contains(permission)
                ? role.permissions.where((p) => p != permission).toList()
                : [...role.permissions, permission],
          )
        else
          role,
    ];

    state = AsyncValue.data(updated);

    // Persist the modified role
    try {
      final modifiedRole = updated.firstWhere((r) => r.id == roleId);
      await _repository.updateRole(modifiedRole);
    } catch (e) {
      debugPrint('[RolesNotifier] Failed to persist role update: $e');
    }
  }

  /// Assign a role to a user profile (admin-only action).
  Future<void> assignRole(String roleId) async {
    // This is handled by ProfileNotifier.updateProfile with the role field
    debugPrint('[RolesNotifier] Role assignment: $roleId');
  }
}
