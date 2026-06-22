import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../widgets/analytics_category_panel.dart';
import '../widgets/analytics_metrics_row.dart';
import '../widgets/analytics_trend_panel.dart';
import '../widgets/analytics_ai_panel.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const LuxuryScaffold(
      route: AppRoutes.analytics,
      title: 'Analytics Atelier',
      header: EditorialHeader(
        eyebrow: 'Enterprise Intelligence',
        title: 'Predictive Performance Canvas',
        subtitle: 'Layered analytics for sales momentum, stock turnover, and operational confidence.',
      ),
      children: [
        AnalyticsMetricsRow(),
        const SizedBox(height: 12),
        AnalyticsTrendPanel(),
        const SizedBox(height: 12),
        AnalyticsCategoryPanel(),
        const SizedBox(height: 12),
        AnalyticsAiPanel(),
      ],
    );
  }
}
