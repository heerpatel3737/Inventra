import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../models/product_model.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/product_card.dart';
import '../providers/products_providers.dart';

class ProductsCatalogSection extends ConsumerWidget {
  const ProductsCatalogSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final isGrid = ref.watch(productsGridModeProvider);

    if (products.isEmpty) {
      return const AppEmptyView(
        title: 'No products found',
        subtitle: 'Try another search/filter or add a new product.',
        icon: Icons.inventory_2_outlined,
      );
    }

    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Helpers.responsiveGridCount(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) => _ProductTile(product: products[index]),
      );
    }

    return Column(
      children: products
          .map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 164,
                child: _ProductTile(product: product),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  final ProductModel product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProductCard(
      product: product,
      onTap: () {
        ref.read(selectedProductProvider.notifier).state = product;
        Navigator.pushNamed(context, AppRoutes.productDetails);
      },
      onDelete: () async {
        final id = product.id;
        if (id == null) return;

        await ref.read(productsProvider.notifier).deleteProduct(id);
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Product Deleted');
        }
      },
    );
  }
}
