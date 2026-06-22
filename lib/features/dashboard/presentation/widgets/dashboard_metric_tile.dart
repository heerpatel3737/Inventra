import 'package:flutter/material.dart';

import '../../../../widgets/cards/metric_card.dart';
import '../../domain/dashboard_models.dart';

/// Reusable KPI tile used only by dashboard metrics grid.
class DashboardMetricTile extends StatelessWidget {
  final DashboardMetric metric;

  const DashboardMetricTile({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return MetricCard(
      label: metric.label,
      value: metric.value,
      caption: metric.caption,
      icon: metric.icon,
    );
  }
}
