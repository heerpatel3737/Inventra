import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/sales_model.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/sales_status_chip.dart';
import '../providers/sales_providers.dart';

class SalesTransactionsTable extends ConsumerWidget {
  const SalesTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(filteredSalesProvider);

    if (sales.isEmpty) {
      return const AppEmptyView(
        title: 'No transactions found',
        subtitle: 'Try another filter or record a new sale.',
        icon: Icons.receipt_long_outlined,
      );
    }

    final isCompact = MediaQuery.sizeOf(context).width < 760;

    if (isCompact) {
      return Column(
        children: sales.map((sale) => _SalesMobileTile(sale: sale)).toList(),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Order')),
                  DataColumn(label: Text('Client')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Action')),
                ],
                rows: sales
                    .map(
                      (sale) => DataRow(
                        cells: [
                          DataCell(Text(sale.orderCode)),
                          DataCell(Text(sale.clientName)),
                          DataCell(SalesStatusChip(status: sale.status)),
                          DataCell(Text(formatSalesCurrency(sale.amount))),
                          DataCell(
                            IconButton(
                              onPressed: () async {
                                await ref.read(salesProvider.notifier).deleteSale(sale.id);
                                if (context.mounted) {
                                  AppSnackbar.showSuccess(context, 'Sale Deleted');
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
}

class _SalesMobileTile extends ConsumerWidget {
  final SalesModel sale;

  const _SalesMobileTile({required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(sale.clientName),
        subtitle: Text('${sale.orderCode} • ${_formatDate(sale.createdAt)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatSalesCurrency(sale.amount),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            SalesStatusChip(status: sale.status),
          ],
        ),
        onLongPress: () => ref.read(salesProvider.notifier).deleteSale(sale.id),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
