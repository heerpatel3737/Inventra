import 'package:flutter/material.dart';

import '../../../../core/utils/helpers.dart';
import '../../domain/dashboard_models.dart';
import 'dashboard_metric_tile.dart';

class DashboardMetricsGrid extends StatelessWidget {
  final List<DashboardMetric> metrics;

  const DashboardMetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Helpers.responsiveGridCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        return DashboardMetricTile(metric: metrics[index]);
      },
    );
  }
}
