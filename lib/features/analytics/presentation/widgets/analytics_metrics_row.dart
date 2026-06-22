import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/cards/metric_card.dart';
import '../providers/analytics_providers.dart';

class AnalyticsMetricsRow extends ConsumerWidget {
  const AnalyticsMetricsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growth = ref.watch(revenueGrowthProvider);
    final turnover = ref.watch(inventoryTurnoverProvider);
    final accuracy = ref.watch(orderAccuracyProvider);

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            label: 'Growth',
            value: growth,
            caption: 'Month-over-month revenue momentum',
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            label: 'Turnover',
            value: turnover,
            caption: 'Revenue velocity against catalog value',
            icon: Icons.loop_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            label: 'Order Accuracy',
            value: accuracy,
            caption: 'Paid orders vs total order volume',
            icon: Icons.verified_rounded,
          ),
        ),
      ],
    );
  }
}
