import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database_helper.dart';
import '../features/categories/presentation/providers/categories_providers.dart';
import '../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../features/notifications/presentation/providers/notifications_providers.dart';
import '../features/purchases/presentation/providers/purchases_providers.dart';
import '../features/sales/presentation/providers/sales_providers.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import '../features/suppliers/presentation/providers/suppliers_providers.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../services/sync_service.dart';

/// Binds the authenticated Firebase uid to local storage and Firestore sync.
final userSessionProvider = Provider<void>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  final db = DatabaseHelper.instance;
  final previousUid = db.currentUserId;

  db.setCurrentUserId(uid);
  SyncService.instance.setUserId(uid);

  if (uid != null) {
    SyncService.instance.syncQueue();
    SyncService.instance.startRealtimeSync();
  } else {
    SyncService.instance.stopRealtimeSync();
  }

  if (previousUid != uid) {
    ref.invalidate(productsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(suppliersProvider);
    ref.invalidate(salesProvider);
    ref.invalidate(purchasesProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(profileProvider);
    ref.invalidate(rolesProvider);
    ref.invalidate(syncStatusProvider);
    ref.invalidate(dashboardBaseProvider);
  }
});

/// Convenience accessor for the current authenticated uid.
final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(userSessionProvider);
  return ref.watch(authStateProvider).valueOrNull?.uid;
});
