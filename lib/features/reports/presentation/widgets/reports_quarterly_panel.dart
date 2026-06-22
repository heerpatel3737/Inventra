import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../purchases/presentation/providers/purchases_providers.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../providers/reports_providers.dart';

class ReportsQuarterlyPanel extends ConsumerWidget {
  const ReportsQuarterlyPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenue = ref.watch(quarterlyRevenueProvider);
    final spend = ref.watch(quarterlyPurchaseSpendProvider);
    final net = revenue - spend;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quarterly Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Executive reporting canvas for board-level visibility.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _StatTile(label: 'Revenue', value: formatSalesCurrency(revenue))),
                const SizedBox(width: 10),
                Expanded(child: _StatTile(label: 'Procurement', value: formatPurchaseCurrency(spend))),
                const SizedBox(width: 10),
                Expanded(child: _StatTile(label: 'Net Position', value: formatSalesCurrency(net))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
