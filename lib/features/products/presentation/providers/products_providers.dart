import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/product_model.dart';
import '../../../../providers/product_provider.dart';

// Core product + dashboard providers live in product_provider.dart.
export '../../../../providers/product_provider.dart'
    show
        catalogValueProvider,
        databaseHelperProvider,
        lowStockCountProvider,
        lowStockProductsProvider,
        productCountProvider,
        productsProvider,
        productsRefreshProvider,
        productsRepositoryProvider;

/// UI-only state: true = grid, false = list.
final productsGridModeProvider = StateProvider<bool>((ref) => true);

/// Search text entered by user.
final productSearchQueryProvider = StateProvider<String>((ref) => '');

/// Category filter chip value.
final productCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// Selected product for details / edit navigation.
final selectedProductProvider = StateProvider<ProductModel?>((ref) => null);

/// Filtered list used by products screen UI.
final filteredProductsProvider = Provider<List<ProductModel>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final query = ref.watch(productSearchQueryProvider).trim().toLowerCase();
  final category = ref.watch(productCategoryFilterProvider);

  return productsAsync.maybeWhen(
    data: (products) {
      return products.where((product) {
        final matchesCategory = category == 'All' ||
            (category == 'Low Stock'
                ? product.stock <= 5
                : product.category == category);

        final matchesQuery = query.isEmpty ||
            product.name.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query) ||
            product.supplier.toLowerCase().contains(query) ||
            product.id.toString().contains(query) ||
            product.skuLabel.toLowerCase().contains(query);

        return matchesCategory && matchesQuery;
      }).toList();
    },
    orElse: () => <ProductModel>[],
  );
});
