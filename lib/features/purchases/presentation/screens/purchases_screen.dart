import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/purchases_providers.dart';
import '../widgets/purchase_form_dialog.dart';
import '../widgets/purchases_filter_chips.dart';
import '../widgets/purchases_metrics_row.dart';
import '../widgets/purchases_orders_table.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesProvider);
    final refreshPurchases = ref.read(purchasesRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.purchases,
      title: 'Purchases',
      header: const EditorialHeader(
        eyebrow: 'Supply Strategy',
        title: 'Purchase Intelligence',
        subtitle: 'Manage procurement flow, approvals, and incoming shipments reactively.',
      ),
      children: [
        LuxuryButton(
          label: 'Create Purchase Order',
          icon: Icons.add_rounded,
          onPressed: () => openPurchaseFormDialog(context),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search PO, supplier, status...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) => ref.read(purchaseSearchQueryProvider.notifier).state = value,
        ),
        const SizedBox(height: 12),
        const PurchasesFilterChips(),
        const SizedBox(height: 14),
        purchasesAsync.when(
          loading: () => const AppLoadingView(message: 'Loading purchase orders...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load purchases.\n$error',
            onRetry: refreshPurchases,
          ),
          data: (_) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PurchasesMetricsRow(),
              SizedBox(height: 14),
              PurchasesOrdersTable(),
            ],
          ),
        ),
      ],
    );
  }
}
