import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/reports_providers.dart';
import '../widgets/report_card.dart';
import '../widgets/reports_quarterly_panel.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportSnapshotsProvider);

    return LuxuryScaffold(
      route: AppRoutes.reports,
      title: 'Reports Studio',
      header: const EditorialHeader(
        eyebrow: 'Performance Editorial',
        title: 'Financial & Inventory Reporting',
        subtitle: 'Live report surfaces powered by sales, purchases, and catalog data.',
      ),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: reports.map((report) => ReportCard(report: report)).toList(),
        ),
        const SizedBox(height: 12),
        const ReportsQuarterlyPanel(),
      ],
    );
  }
}
