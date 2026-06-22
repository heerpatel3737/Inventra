import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/cards/metric_card.dart';
import '../providers/sales_providers.dart';

class SalesMetricsRow extends ConsumerWidget {
  const SalesMetricsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRevenue = ref.watch(todayRevenueProvider);
    final conversion = ref.watch(conversionRateProvider);
    final avgOrder = ref.watch(averageOrderValueProvider);

    final cards = [
      MetricCard(
        label: 'Today Revenue',
        value: formatSalesCurrency(todayRevenue),
        caption: 'Completed sales today',
        icon: Icons.payments_outlined,
      ),
      MetricCard(
        label: 'Conversion',
        value: '${conversion.toStringAsFixed(0)}%',
        caption: 'Paid orders ratio',
        icon: Icons.percent_rounded,
      ),
      MetricCard(
        label: 'Avg Order',
        value: formatSalesCurrency(avgOrder),
        caption: 'Average transaction value',
        icon: Icons.show_chart_rounded,
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
