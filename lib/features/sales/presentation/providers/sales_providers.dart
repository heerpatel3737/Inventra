import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/sales_model.dart';
import '../../../../providers/product_provider.dart';
import '../../data/sales_repository.dart';
import 'sales_notifier.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(databaseHelperProvider));
});

final salesProvider = StateNotifierProvider<SalesNotifier, AsyncValue<List<SalesModel>>>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return SalesNotifier(repository);
});

final salesSearchQueryProvider = StateProvider<String>((ref) => '');

final salesStatusFilterProvider = StateProvider<String>((ref) => 'All');

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

final filteredSalesProvider = Provider<List<SalesModel>>((ref) {
  final salesAsync = ref.watch(salesProvider);
  final query = ref.watch(salesSearchQueryProvider).trim().toLowerCase();
  final status = ref.watch(salesStatusFilterProvider);

  return salesAsync.maybeWhen(
    data: (sales) {
      return sales.where((sale) {
        final matchesStatus = status == 'All' || sale.status == status;
        final matchesQuery = query.isEmpty ||
            sale.clientName.toLowerCase().contains(query) ||
            sale.id.toLowerCase().contains(query) ||
            sale.status.toLowerCase().contains(query);
        return matchesStatus && matchesQuery;
      }).toList();
    },
    orElse: () => <SalesModel>[],
  );
});

final todayRevenueProvider = Provider<double>((ref) {
  final salesAsync = ref.watch(salesProvider);
  final today = DateTime.now();

  return salesAsync.maybeWhen(
    data: (sales) => sales
        .where((sale) => _isSameDay(sale.createdAt, today))
        .fold<double>(0, (sum, sale) => sum + sale.amount),
    orElse: () => 0,
  );
});

final totalRevenueProvider = Provider<double>((ref) {
  final salesAsync = ref.watch(salesProvider);
  return salesAsync.maybeWhen(
    data: (sales) => sales.fold<double>(0, (sum, sale) => sum + sale.amount),
    orElse: () => 0,
  );
});

final completedOrdersProvider = Provider<int>((ref) {
  final salesAsync = ref.watch(salesProvider);
  return salesAsync.maybeWhen(
    data: (sales) => sales.where((sale) => sale.status == 'Paid' || sale.status == 'Shipped').length,
    orElse: () => 0,
  );
});

final salesCountProvider = Provider<int>((ref) {
  final salesAsync = ref.watch(salesProvider);
  return salesAsync.maybeWhen(
    data: (sales) => sales.length,
    orElse: () => 0,
  );
});

final averageOrderValueProvider = Provider<double>((ref) {
  final total = ref.watch(totalRevenueProvider);
  final count = ref.watch(salesCountProvider);
  if (count == 0) return 0;
  return total / count;
});

final conversionRateProvider = Provider<double>((ref) {
  final salesAsync = ref.watch(salesProvider);
  return salesAsync.maybeWhen(
    data: (sales) {
      if (sales.isEmpty) return 0;
      final completed = sales.where((s) => s.status == 'Paid').length;
      return (completed / sales.length) * 100;
    },
    orElse: () => 0,
  );
});

final salesRefreshProvider = Provider<void Function()>((ref) {
  return () => ref.read(salesProvider.notifier).loadSales();
});

String formatSalesCurrency(double value) {
  if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';
  return '\$${value.toStringAsFixed(0)}';
}
