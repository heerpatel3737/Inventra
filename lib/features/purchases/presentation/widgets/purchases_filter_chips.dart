import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/purchases_providers.dart';

class PurchasesFilterChips extends ConsumerWidget {
  const PurchasesFilterChips({super.key});

  static const _filters = ['All', 'Pending', 'Approved', 'Received', 'Cancelled'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(purchaseStatusFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters.map((filter) {
        return FilterChip(
          label: Text(filter),
          selected: selected == filter,
          onSelected: (_) => ref.read(purchaseStatusFilterProvider.notifier).state = filter,
        );
      }).toList(),
    );
  }
}
