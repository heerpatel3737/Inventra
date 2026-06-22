import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/cards/metric_card.dart';
import '../providers/purchases_providers.dart';

class PurchasesMetricsRow extends ConsumerWidget {
  const PurchasesMetricsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openOrders = ref.watch(openPurchaseOrdersProvider);
    final incoming = ref.watch(incomingShipmentsProvider);
    final spend = ref.watch(totalPurchaseSpendProvider);

    final cards = [
      MetricCard(
        label: 'Open POs',
        value: '$openOrders',
        caption: 'Pending or approved orders',
        icon: Icons.shopping_bag_outlined,
      ),
      MetricCard(
        label: 'Incoming',
        value: '$incoming',
        caption: 'Shipments scheduled',
        icon: Icons.local_shipping_outlined,
      ),
      MetricCard(
        label: 'Total Spend',
        value: formatPurchaseCurrency(spend),
        caption: 'Procurement value',
        icon: Icons.payments_outlined,
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
