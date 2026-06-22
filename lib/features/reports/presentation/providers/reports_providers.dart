import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/providers/products_providers.dart';
import '../../../purchases/presentation/providers/purchases_providers.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../../../suppliers/presentation/providers/suppliers_providers.dart';
import '../../../../services/report_export_service.dart';

final reportExportServiceProvider = Provider<ReportExportService>((ref) => ReportExportService());

class ReportSnapshot {
  final String id;
  final String title;
  final String description;
  final String metricLabel;
  final String metricValue;
  final String metricCaption;

  const ReportSnapshot({
    required this.id,
    required this.title,
    required this.description,
    required this.metricLabel,
    required this.metricValue,
    required this.metricCaption,
  });
}

final reportSnapshotsProvider = Provider<List<ReportSnapshot>>((ref) {
  final catalogValue = ref.watch(catalogValueProvider);
  final productCount = ref.watch(productCountProvider);
  final totalRevenue = ref.watch(totalRevenueProvider);
  final completedOrders = ref.watch(completedOrdersProvider);
  final conversion = ref.watch(conversionRateProvider);
  final suppliers = ref.watch(suppliersProvider);
  final activeSuppliers = suppliers.where((s) => s.status == 'Active').length;
  final purchaseSpend = ref.watch(totalPurchaseSpendProvider);

  return [
    ReportSnapshot(
      id: 'inventory-valuation',
      title: 'Inventory Valuation',
      description: 'Category-wise stock value insights with trend overlays.',
      metricLabel: 'Catalog Value',
      metricValue: formatSalesCurrency(catalogValue),
      metricCaption: '$productCount SKUs tracked in catalog',
    ),
    ReportSnapshot(
      id: 'sales-performance',
      title: 'Sales Performance',
      description: 'Revenue movement, conversion insights, and order summaries.',
      metricLabel: 'Total Revenue',
      metricValue: formatSalesCurrency(totalRevenue),
      metricCaption: '$completedOrders fulfilled • ${conversion.toStringAsFixed(1)}% paid conversion',
    ),
    ReportSnapshot(
      id: 'supplier-performance',
      title: 'Supplier Performance',
      description: 'Lead times, reliability scoring, and procurement visibility.',
      metricLabel: 'Active Suppliers',
      metricValue: '$activeSuppliers / ${suppliers.length}',
      metricCaption: '${formatPurchaseCurrency(purchaseSpend)} total procurement spend',
    ),
  ];
});

final quarterlyRevenueProvider = Provider<double>((ref) {
  final salesAsync = ref.watch(salesProvider);
  final now = DateTime.now();
  final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;

  return salesAsync.maybeWhen(
    data: (sales) => sales
        .where((sale) {
          final inQuarter = sale.createdAt.year == now.year && sale.createdAt.month >= quarterStartMonth;
          return inQuarter;
        })
        .fold<double>(0, (sum, sale) => sum + sale.amount),
    orElse: () => 0,
  );
});

final quarterlyPurchaseSpendProvider = Provider<double>((ref) {
  final purchasesAsync = ref.watch(purchasesProvider);
  final now = DateTime.now();
  final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;

  return purchasesAsync.maybeWhen(
    data: (purchases) => purchases
        .where((purchase) {
          return purchase.createdAt.year == now.year && purchase.createdAt.month >= quarterStartMonth;
        })
        .fold<double>(0, (sum, purchase) => sum + purchase.amount),
    orElse: () => 0,
  );
});
