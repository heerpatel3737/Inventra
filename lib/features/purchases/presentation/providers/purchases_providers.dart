import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/purchase_model.dart';
import '../../../../providers/product_provider.dart';
import '../../data/purchases_repository.dart';
import 'purchases_notifier.dart';

final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) {
  return PurchasesRepository(ref.watch(databaseHelperProvider));
});

final purchasesProvider = StateNotifierProvider<PurchasesNotifier, AsyncValue<List<PurchaseModel>>>((ref) {
  final repository = ref.watch(purchasesRepositoryProvider);
  return PurchasesNotifier(repository);
});

final purchaseSearchQueryProvider = StateProvider<String>((ref) => '');

final purchaseStatusFilterProvider = StateProvider<String>((ref) => 'All');

final filteredPurchasesProvider = Provider<List<PurchaseModel>>((ref) {
  final purchasesAsync = ref.watch(purchasesProvider);
  final query = ref.watch(purchaseSearchQueryProvider).trim().toLowerCase();
  final status = ref.watch(purchaseStatusFilterProvider);

  return purchasesAsync.maybeWhen(
    data: (purchases) {
      return purchases.where((purchase) {
        final matchesStatus = status == 'All' || purchase.status == status;
        final matchesQuery = query.isEmpty ||
            purchase.supplierName.toLowerCase().contains(query) ||
            purchase.id.toLowerCase().contains(query) ||
            purchase.status.toLowerCase().contains(query);
        return matchesStatus && matchesQuery;
      }).toList();
    },
    orElse: () => <PurchaseModel>[],
  );
});

final openPurchaseOrdersProvider = Provider<int>((ref) {
  final purchasesAsync = ref.watch(purchasesProvider);
  return purchasesAsync.maybeWhen(
    data: (purchases) => purchases.where((p) => p.status == 'Pending' || p.status == 'Approved').length,
    orElse: () => 0,
  );
});

final incomingShipmentsProvider = Provider<int>((ref) {
  final purchasesAsync = ref.watch(purchasesProvider);
  final now = DateTime.now();

  return purchasesAsync.maybeWhen(
    data: (purchases) => purchases
        .where((p) => p.status == 'Approved' && p.expectedDelivery.isAfter(now))
        .length,
    orElse: () => 0,
  );
});

final totalPurchaseSpendProvider = Provider<double>((ref) {
  final purchasesAsync = ref.watch(purchasesProvider);
  return purchasesAsync.maybeWhen(
    data: (purchases) => purchases.fold<double>(0, (sum, p) => sum + p.amount),
    orElse: () => 0,
  );
});

final purchasesRefreshProvider = Provider<void Function()>((ref) {
  return () => ref.read(purchasesProvider.notifier).loadPurchases();
});

String formatPurchaseCurrency(double value) {
  if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';
  return '\$${value.toStringAsFixed(0)}';
}
