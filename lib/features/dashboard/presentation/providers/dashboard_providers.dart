import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/product_provider.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../../../suppliers/presentation/providers/suppliers_providers.dart';
import '../../../purchases/presentation/providers/purchases_providers.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_models.dart';

/// Repository provider: now accepts DatabaseHelper for live data.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(databaseHelperProvider));
});

/// Loads dashboard data from real SQLite data.
final dashboardBaseProvider = FutureProvider<DashboardData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.fetchDashboard();
});

/// Reactive dashboard provider.
/// Rebuilds automatically when product/sales/supplier state changes.
final dashboardProvider = Provider<AsyncValue<DashboardData>>((ref) {
  // Watch all data providers so dashboard auto-refreshes on any change
  ref.watch(productsProvider);
  ref.watch(salesProvider);
  ref.watch(suppliersProvider);
  ref.watch(purchasesProvider);

  final baseAsync = ref.watch(dashboardBaseProvider);

  final productCount = ref.watch(productCountProvider);
  final lowStockCount = ref.watch(lowStockCountProvider);
  final supplierCount = ref.watch(supplierCountProvider);
  final monthlyRevenue = ref.watch(totalRevenueProvider);

  return baseAsync.when(
    data: (data) => AsyncValue.data(
      data.withLiveCounts(
        productCount: productCount,
        lowStockCount: lowStockCount,
        supplierCount: supplierCount,
        monthlyRevenue: monthlyRevenue,
      ),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Manual refresh action for pull-to-refresh / retry buttons.
final dashboardRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(dashboardBaseProvider);
  };
});
