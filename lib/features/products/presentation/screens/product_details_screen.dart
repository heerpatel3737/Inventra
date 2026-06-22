import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../models/product_model.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/charts/chart_placeholder.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/products_providers.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(selectedProductProvider);

    if (product == null) {
      return LuxuryScaffold(
        route: AppRoutes.productDetails,
        title: 'Product Dossier',
        children: [
          AppEmptyView(
            title: 'No product selected',
            subtitle: 'Open a product from the catalog to view details.',
            icon: Icons.inventory_2_outlined,
          ),
        ],
      );
    }

    return LuxuryScaffold(
      route: AppRoutes.productDetails,
      title: 'Product Dossier',
      header: EditorialHeader(
        eyebrow: 'Editorial Product View',
        title: product.name,
        subtitle: '${product.skuLabel} • ${product.category} • ${_stockLabel(product.stock)}',
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(title: const Text('Supplier'), subtitle: Text(product.supplier)),
                ListTile(title: const Text('Category'), subtitle: Text(product.category)),
                ListTile(title: const Text('Stock'), subtitle: Text('${product.stock} units available')),
                ListTile(title: const Text('Product ID'), subtitle: Text(product.skuLabel)),
                ListTile(title: const Text('Price'), subtitle: Text('\$${product.price.toStringAsFixed(2)}')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: LuxuryButton(
                label: 'Edit Product',
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addProduct,
                    arguments: product,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LuxuryButton(
                label: 'Delete Product',
                icon: Icons.delete_outline_rounded,
                outlined: true,
                onPressed: () => _deleteProduct(context, ref, product),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const ChartPlaceholder(
          title: 'Demand Trajectory',
          subtitle: 'Product movement trend across the last 90 days.',
          icon: Icons.query_stats_rounded,
          height: 180,
        ),
      ],
    );
  }

  String _stockLabel(int stock) {
    if (stock <= 5) return 'Low Stock';
    if (stock <= 15) return 'Moderate Stock';
    return 'Healthy Stock';
  }

  Future<void> _deleteProduct(BuildContext context, WidgetRef ref, ProductModel product) async {
    final id = product.id;
    if (id == null) return;

    await ref.read(productsProvider.notifier).deleteProduct(id);
    ref.read(selectedProductProvider.notifier).state = null;

    if (!context.mounted) return;

    AppSnackbar.showSuccess(context, 'Product Deleted');
    Navigator.pop(context);
  }
}
