import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/product_model.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../../sales/presentation/providers/sales_providers.dart';

final revenueGrowthProvider = Provider<String>((ref) {
  final salesAsync = ref.watch(salesProvider);
  return salesAsync.maybeWhen(
    data: (sales) {
      final now = DateTime.now();
      final thisMonthRevenue = sales
          .where((sale) => sale.createdAt.year == now.year && sale.createdAt.month == now.month)
          .fold<double>(0, (sum, sale) => sum + sale.amount);

      final previousMonth = DateTime(now.year, now.month - 1);
      final lastMonthRevenue = sales
          .where((sale) =>
              sale.createdAt.year == previousMonth.year && sale.createdAt.month == previousMonth.month)
          .fold<double>(0, (sum, sale) => sum + sale.amount);

      if (lastMonthRevenue == 0) return '+0.0%';
      final growth = ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
      return '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%';
    },
    orElse: () => '—',
  );
});

final inventoryTurnoverProvider = Provider<String>((ref) {
  final revenue = ref.watch(totalRevenueProvider);
  final catalogValue = ref.watch(catalogValueProvider);
  if (catalogValue <= 0) return '—';
  final turnover = revenue / catalogValue;
  return '${turnover.toStringAsFixed(1)}x';
});

final orderAccuracyProvider = Provider<String>((ref) {
  final rate = ref.watch(conversionRateProvider);
  return '${rate.toStringAsFixed(1)}%';
});

class CategoryShare {
  final String category;
  final int count;
  final double share;

  const CategoryShare({
    required this.category,
    required this.count,
    required this.share,
  });
}

final categoryDistributionProvider = Provider<List<CategoryShare>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.maybeWhen(
    data: (products) => _buildCategoryShares(products),
    orElse: () => <CategoryShare>[],
  );
});

List<CategoryShare> _buildCategoryShares(List<ProductModel> products) {
  if (products.isEmpty) return [];

  final counts = <String, int>{};
  for (final product in products) {
    counts[product.category] = (counts[product.category] ?? 0) + 1;
  }

  final total = products.length;
  final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  return entries
      .map(
        (entry) => CategoryShare(
          category: entry.key,
          count: entry.value,
          share: (entry.value / total) * 100,
        ),
      )
      .toList();
}

class MonthlyTrendPoint {
  final String label;
  final double revenue;

  const MonthlyTrendPoint({required this.label, required this.revenue});
}

final monthlyTrendProvider = Provider<List<MonthlyTrendPoint>>((ref) {
  final salesAsync = ref.watch(salesProvider);
  return salesAsync.maybeWhen(
    data: (sales) {
      final now = DateTime.now();
      final points = <MonthlyTrendPoint>[];

      for (var i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i);
        final revenue = sales
            .where((sale) =>
                sale.createdAt.year == monthDate.year && sale.createdAt.month == monthDate.month)
            .fold<double>(0, (sum, sale) => sum + sale.amount);

        points.add(
          MonthlyTrendPoint(
            label: _monthLabel(monthDate.month),
            revenue: revenue,
          ),
        );
      }

      return points;
    },
    orElse: () => <MonthlyTrendPoint>[],
  );
});

String _monthLabel(int month) {
  const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return labels[month - 1];
}

String formatAnalyticsCurrency(double value) {
  if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';
  return '\$${value.toStringAsFixed(0)}';
}
