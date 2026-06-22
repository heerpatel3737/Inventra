import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../providers/reports_providers.dart';

class ReportCard extends ConsumerStatefulWidget {
  final ReportSnapshot report;

  const ReportCard({super.key, required this.report});

  @override
  ConsumerState<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<ReportCard> {
  bool _isExporting = false;

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      final exportService = ref.read(reportExportServiceProvider);
      String result = '';

      if (widget.report.id == 'inventory-valuation') {
        final products = ref.read(productsProvider).value ?? [];
        result = await exportService.exportInventoryValuation(products);
      } else if (widget.report.id == 'sales-performance') {
        final sales = ref.read(salesProvider).value ?? [];
        result = await exportService.exportSalesMomentum(sales);
      } else {
        final products = ref.read(productsProvider).value ?? [];
        result = await exportService.exportReorderAlerts(products);
      }

      if (mounted) {
        AppSnackbar.showSuccess(context, 'PDF Exported: $result');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.report.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(widget.report.description),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.report.metricLabel, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      widget.report.metricValue,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.report.metricCaption, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isExporting ? null : _export,
                icon: const Icon(Icons.download_rounded),
                label: Text(_isExporting ? 'Exporting...' : 'Export'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
