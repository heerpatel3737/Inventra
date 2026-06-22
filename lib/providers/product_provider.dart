import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database_helper.dart';
import '../data/models/product_model.dart';
import '../features/products/data/products_repository.dart';
import '../services/api_service.dart';

/// Provider for API Service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// ---------------------------------------------------------------------------
// Data layer providers
// ---------------------------------------------------------------------------

/// Single shared [DatabaseHelper] instance for the whole app.
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// Repository bridges UI/state layer and SQLite CRUD.
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.watch(databaseHelperProvider));
});

// ---------------------------------------------------------------------------
// Product list state (async + CRUD)
// ---------------------------------------------------------------------------

/// Loads and mutates the product catalog.
///
/// Provider flow:
/// UI watches [productsProvider] → [ProductsNotifier] calls [ProductsRepository]
/// → [DatabaseHelper] reads/writes SQLite → notifier reloads list → UI rebuilds.
final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<ProductModel>>>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return ProductsNotifier(repository);
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  ProductsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  final ProductsRepository _repository;

  /// READ — fetches all rows from SQLite and exposes them as [AsyncValue.data].
  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchProducts);
  }

  /// CREATE — inserts into SQLite, then reloads so every listener updates.
  Future<void> addProduct({
    required String name,
    required String category,
    required String supplier,
    required int stock,
    required double price,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repository.addProduct(
        name: name.trim(),
        category: category,
        supplier: supplier,
        stock: stock,
        price: price,
      );
      return _repository.fetchProducts();
    });
  }

  /// UPDATE — saves edits for an existing product, then reloads the list.
  Future<void> updateProduct(ProductModel product) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repository.updateProduct(product);
      return _repository.fetchProducts();
    });
  }

  /// DELETE — removes by id, then reloads the list.
  Future<void> deleteProduct(int productId) async {
    final previous = state;
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repository.deleteProduct(productId);
      return _repository.fetchProducts();
    });

    if (state.hasError) {
      state = previous;
    }
  }
}

// ---------------------------------------------------------------------------
// Derived providers (dashboard + catalog helpers)
// ---------------------------------------------------------------------------

/// Total product count for dashboard metrics.
final productCountProvider = Provider<int>((ref) {
  return ref.watch(productsProvider).maybeWhen(
        data: (products) => products.length,
        orElse: () => 0,
      );
});

/// Products at or below the low-stock threshold (5 units).
final lowStockCountProvider = Provider<int>((ref) {
  return ref.watch(productsProvider).maybeWhen(
        data: (products) => products.where((product) => product.stock <= 5).length,
        orElse: () => 0,
      );
});

/// Sum of (price × stock) for catalog valuation.
final catalogValueProvider = Provider<double>((ref) {
  return ref.watch(productsProvider).maybeWhen(
        data: (products) =>
            products.fold<double>(0, (sum, product) => sum + (product.price * product.stock)),
        orElse: () => 0,
      );
});

/// Pull-to-refresh / manual reload callback.
final productsRefreshProvider = Provider<void Function()>((ref) {
  return () => ref.read(productsProvider.notifier).loadProducts();
});

/// Low-stock products sorted ascending by quantity (alerts screen).
final lowStockProductsProvider = Provider<List<ProductModel>>((ref) {
  return ref.watch(productsProvider).maybeWhen(
        data: (products) {
          final lowStock = products.where((product) => product.stock <= 5).toList();
          lowStock.sort((a, b) => a.stock.compareTo(b.stock));
          return lowStock;
        },
        orElse: () => <ProductModel>[],
      );
});
