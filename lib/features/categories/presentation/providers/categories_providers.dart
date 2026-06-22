import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/category_model.dart';
import '../../../../providers/product_provider.dart';
import '../../data/categories_repository.dart';
import 'categories_notifier.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(databaseHelperProvider));
});

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return CategoriesNotifier(repository);
});

/// Dropdown options for product forms (reactive).
final categoryOptionsProvider = Provider<List<String>>((ref) {
  return ref.watch(categoriesProvider).map((category) => category.name).toList();
});

/// Categories enriched with dynamic product counts computed from actual inventory.
/// This provider maps each category's name to the real count of products in that category.
final categoriesWithCountsProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.maybeWhen(
    data: (products) {
      // Build a map of category name -> product count
      final countMap = <String, int>{};
      for (final product in products) {
        final key = product.category.toLowerCase().trim();
        countMap[key] = (countMap[key] ?? 0) + 1;
      }

      // Return categories with live product counts
      return categories.map((category) {
        final count = countMap[category.name.toLowerCase().trim()] ?? 0;
        return category.copyWith(totalProducts: count);
      }).toList();
    },
    orElse: () => categories,
  );
});
