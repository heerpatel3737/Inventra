import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/cards/metric_card.dart';
import '../providers/products_providers.dart';

class ProductsMetricsRow extends ConsumerWidget {
  const ProductsMetricsRow({super.key});

  String _formatCurrency(double value) {
    if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';
    return '\$${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogValue = ref.watch(catalogValueProvider);
    final productCount = ref.watch(productCountProvider);
    final lowStockCount = ref.watch(lowStockCountProvider);

    final cards = [
      MetricCard(
        label: 'Catalog Value',
        value: _formatCurrency(catalogValue),
        caption: 'Price x stock valuation',
        icon: Icons.sell_outlined,
      ),
      MetricCard(
        label: 'Active SKUs',
        value: '$productCount',
        caption: 'Products in catalog',
        icon: Icons.inventory_2_outlined,
      ),
      MetricCard(
        label: 'Low Stock',
        value: '$lowStockCount',
        caption: 'Needs restock action',
        icon: Icons.warning_amber_outlined,
      ),
    ];

    final isCompact = MediaQuery.sizeOf(context).width < 900;
    if (isCompact) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 12),
        Expanded(child: cards[1]),
        const SizedBox(width: 12),
        Expanded(child: cards[2]),
      ],
    );
  }
}
