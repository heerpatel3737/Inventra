import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sales_providers.dart';

class SalesFilterChips extends ConsumerWidget {
  const SalesFilterChips({super.key});

  static const _filters = ['All', 'Paid', 'Shipped', 'Pending'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(salesStatusFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters.map((filter) {
        return FilterChip(
          label: Text(filter),
          selected: selected == filter,
          onSelected: (_) => ref.read(salesStatusFilterProvider.notifier).state = filter,
        );
      }).toList(),
    );
  }
}
