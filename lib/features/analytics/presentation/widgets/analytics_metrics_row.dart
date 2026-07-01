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

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    final cards = [
      MetricCard(
        label: 'Growth',
        value: growth,
        caption: 'Month-over-month revenue momentum',
        icon: Icons.trending_up_rounded,
      ),
      MetricCard(
        label: 'Turnover',
        value: turnover,
        caption: 'Revenue velocity against catalog value',
        icon: Icons.loop_rounded,
      ),
      MetricCard(
        label: 'Order Accuracy',
        value: accuracy,
        caption: 'Paid orders vs total order volume',
        icon: Icons.verified_rounded,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((card) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: card,
            ),
          );
        }).toList(),
      );
    }

    return Row(
      children: cards.map((card) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: card,
          ),
        );
      }).toList(),
    );
  }
}
