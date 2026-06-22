import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/charts/chart_placeholder.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/sales_providers.dart';
import '../widgets/sale_form_dialog.dart';
import '../widgets/sales_filter_chips.dart';
import '../widgets/sales_metrics_row.dart';
import '../widgets/sales_transactions_table.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);
    final refreshSales = ref.read(salesRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.sales,
      title: 'Sales',
      header: const EditorialHeader(
        eyebrow: 'Revenue Architecture',
        title: 'Sales Intelligence',
        subtitle: 'Track revenue, order flow, and transaction quality in real time.',
      ),
      children: [
        LuxuryButton(
          label: 'Record Sale',
          icon: Icons.add_rounded,
          onPressed: () => openSaleFormDialog(context),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search orders, clients, status...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) => ref.read(salesSearchQueryProvider.notifier).state = value,
        ),
        const SizedBox(height: 12),
        const SalesFilterChips(),
        const SizedBox(height: 14),
        salesAsync.when(
          loading: () => const AppLoadingView(message: 'Loading sales data...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load sales.\n$error',
            onRetry: refreshSales,
          ),
          data: (_) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SalesMetricsRow(),
              SizedBox(height: 14),
              ChartPlaceholder(
                title: 'Order Momentum',
                subtitle: 'Daily revenue and order trend performance.',
                icon: Icons.area_chart_rounded,
              ),
              SizedBox(height: 12),
              SalesTransactionsTable(),
            ],
          ),
        ),
      ],
    );
  }
}
