import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/stock_alert_tile.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../../../products/presentation/providers/products_providers.dart';

class InventoryAlertsScreen extends ConsumerWidget {
  const InventoryAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final lowStock = ref.watch(lowStockProductsProvider);
    final refresh = ref.read(productsRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.inventoryAlerts,
      title: 'Stock Alerts',
      header: EditorialHeader(
        eyebrow: 'Risk Monitoring',
        title: 'Inventory Alert Ledger',
        subtitle: lowStock.isEmpty
            ? 'No critical stock anomalies detected.'
            : '${lowStock.length} products require restock attention.',
      ),
      children: [
        productsAsync.when(
          loading: () => const AppLoadingView(message: 'Loading stock alerts...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load stock alerts.\n$error',
            onRetry: refresh,
          ),
          data: (_) {
            if (lowStock.isEmpty) {
              return const AppEmptyView(
                title: 'All stock levels healthy',
                subtitle: 'Products above threshold will appear here automatically.',
                icon: Icons.check_circle_outline_rounded,
              );
            }

            return Column(
              children: lowStock
                  .map(
                    (product) => StockAlertTile(
                      productName: product.name,
                      quantityLeft: product.stock,
                      isCritical: product.stock <= 3,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
