import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/purchase_model.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/purchase_status_chip.dart';
import '../providers/purchases_providers.dart';

class PurchasesOrdersTable extends ConsumerWidget {
  const PurchasesOrdersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(filteredPurchasesProvider);

    if (purchases.isEmpty) {
      return const AppEmptyView(
        title: 'No purchase orders found',
        subtitle: 'Try another filter or create a new purchase order.',
        icon: Icons.shopping_bag_outlined,
      );
    }

    final isCompact = MediaQuery.sizeOf(context).width < 760;

    if (isCompact) {
      return Column(
        children: purchases.map((purchase) => _PurchaseMobileTile(purchase: purchase)).toList(),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Purchase Orders', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('PO')),
                  DataColumn(label: Text('Supplier')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('ETA')),
                  DataColumn(label: Text('Action')),
                ],
                rows: purchases
                    .map(
                      (purchase) => DataRow(
                        cells: [
                          DataCell(Text(purchase.orderCode)),
                          DataCell(Text(purchase.supplierName)),
                          DataCell(PurchaseStatusChip(status: purchase.status)),
                          DataCell(Text(formatPurchaseCurrency(purchase.amount))),
                          DataCell(Text(_formatDate(purchase.expectedDelivery))),
                          DataCell(
                            IconButton(
                              onPressed: () async {
                                await ref.read(purchasesProvider.notifier).deletePurchase(purchase.id);
                                if (context.mounted) {
                                  AppSnackbar.showSuccess(context, 'Purchase Deleted');
                                }
                              },
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PurchaseMobileTile extends ConsumerWidget {
  final PurchaseModel purchase;

  const _PurchaseMobileTile({required this.purchase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(purchase.supplierName),
        subtitle: Text('${purchase.orderCode} • ETA ${PurchasesOrdersTable._formatDate(purchase.expectedDelivery)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPurchaseCurrency(purchase.amount),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            PurchaseStatusChip(status: purchase.status),
          ],
        ),
        onLongPress: () async {
          await ref.read(purchasesProvider.notifier).deletePurchase(purchase.id);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'Purchase Deleted');
          }
        },
      ),
    );
  }
}
