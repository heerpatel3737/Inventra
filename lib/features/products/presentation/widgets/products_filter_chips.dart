import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/presentation/providers/categories_providers.dart';
import '../providers/products_providers.dart';

class ProductsFilterChips extends ConsumerWidget {
  const ProductsFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(productCategoryFilterProvider);
    final categories = ref.watch(categoryOptionsProvider);

    final filters = ['All', ...categories, 'Low Stock'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((filter) {
        final isSelected = selected == filter;
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) => ref.read(productCategoryFilterProvider.notifier).state = filter,
        );
      }).toList(),
    );
  }
}
