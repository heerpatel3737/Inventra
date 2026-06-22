import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/role_model.dart';
import '../../../../models/sync_status_model.dart';
import '../../../../models/user_profile_model.dart';
import '../../../../providers/product_provider.dart';
import '../../data/settings_repository.dart';
import 'profile_notifier.dart';
import 'roles_notifier.dart';
import 'sync_notifier.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseHelperProvider));
});

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfileModel>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ProfileNotifier(repository);
});

final rolesProvider = StateNotifierProvider<RolesNotifier, AsyncValue<List<RoleModel>>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return RolesNotifier(repository);
});

final syncStatusProvider = StateNotifierProvider<SyncNotifier, AsyncValue<SyncStatusModel>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SyncNotifier(repository);
});

final profileRefreshProvider = Provider<void Function()>((ref) {
  return () => ref.read(profileProvider.notifier).loadProfile();
});

final rolesRefreshProvider = Provider<void Function()>((ref) {
  return () => ref.read(rolesProvider.notifier).loadRoles();
});

final syncRefreshProvider = Provider<void Function()>((ref) {
  return () => ref.read(syncStatusProvider.notifier).loadStatus();
});

String formatSyncTimestamp(DateTime? dateTime) {
  if (dateTime == null) return 'Never synced';
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${_monthName(local.month)} ${local.day}, $hour:$minute $period';
}

String _monthName(int month) {
  const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return names[month - 1];
}
