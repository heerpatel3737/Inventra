import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/products_providers.dart';
import '../../../../providers/product_provider.dart';
import '../../../categories/presentation/providers/categories_providers.dart';
import '../widgets/products_catalog_section.dart';
import '../widgets/products_filter_chips.dart';
import '../widgets/products_metrics_row.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final refreshProducts = ref.read(productsRefreshProvider);
    final isGrid = ref.watch(productsGridModeProvider);

    return LuxuryScaffold(
      route: AppRoutes.products,
      title: 'Product Atelier',
      actions: [
        IconButton(
          onPressed: () => ref.read(productsGridModeProvider.notifier).state = !isGrid,
          icon: Icon(isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
      ),
      header: const EditorialHeader(
        eyebrow: 'Inventory Overview',
        title: 'Product Management',
        subtitle: 'Track stock levels, suppliers, and sales signals from one reactive workspace.',
      ),
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search by name, SKU, category, supplier...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) => ref.read(productSearchQueryProvider.notifier).state = value,
        ),
        const SizedBox(height: 12),
        const ProductsFilterChips(),
        const SizedBox(height: 14),
        productsAsync.when(
          loading: () => const AppLoadingView(message: 'Loading product catalog...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load products.\n$error',
            onRetry: refreshProducts,
          ),
          data: (_) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductsMetricsRow(),
              SizedBox(height: 14),
              ProductsCatalogSection(),
              SizedBox(height: 12),
              _ProductsFooterActions(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductsFooterActions extends ConsumerStatefulWidget {
  const _ProductsFooterActions();

  @override
  ConsumerState<_ProductsFooterActions> createState() => _ProductsFooterActionsState();
}

class _ProductsFooterActionsState extends ConsumerState<_ProductsFooterActions> {
  bool _isImporting = false;

  Future<void> _importProducts() async {
    setState(() => _isImporting = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final fetched = await apiService.fetchAndStoreExternalProducts();
      
      // Reload products and categories providers
      await ref.read(productsProvider.notifier).loadProducts();
      await ref.read(categoriesProvider.notifier).loadCategories();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully imported ${fetched.length} products from FakeStore API!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import products: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LuxuryButton(
            label: 'Refresh Catalog',
            icon: Icons.refresh_rounded,
            outlined: true,
            onPressed: _isImporting ? null : ref.read(productsRefreshProvider),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LuxuryButton(
            label: _isImporting ? 'Importing...' : 'Import API Products',
            icon: Icons.cloud_download_rounded,
            outlined: true,
            onPressed: _isImporting ? null : _importProducts,
          ),
        ),
      ],
    );
  }
}
