import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../widgets/charts/chart_placeholder.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../../../../widgets/layouts/luxury_search_bar.dart';
import '../../domain/dashboard_models.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_insights_row.dart';
import '../widgets/dashboard_metrics_grid.dart';
import '../widgets/dashboard_quick_actions.dart';

/// Dashboard entry screen.
/// Uses Riverpod so KPI cards update when shared inventory state changes.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final refreshDashboard = ref.read(dashboardRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.dashboard,
      title: 'Inventory Intelligence',
      header: const EditorialHeader(
        eyebrow: 'Operational Excellence',
        title: 'Curated Control for Enterprise Inventory',
        subtitle: 'Cinematic visibility across products, revenue, supply chain, and alert intelligence.',
      ),
      children: [
        LuxurySearchBar(
          hint: 'Search products, suppliers, SKUs, transactions...',
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded, color: AppColors.info),
          ),
        ),
        const SizedBox(height: 16),
        dashboardAsync.when(
          loading: () => const AppLoadingView(message: 'Preparing dashboard insights...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load dashboard data.\n$error',
            onRetry: refreshDashboard,
          ),
          data: (data) => _DashboardContent(data: data),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardData data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardMetricsGrid(metrics: data.metrics),
        const SizedBox(height: 16),
        const DashboardQuickActions(),
        const SizedBox(height: 18),
        const ChartPlaceholder(
          title: 'Sales Flow Narrative',
          subtitle: 'Monthly performance curve with trend intelligence and forecast markers.',
          icon: Icons.stacked_line_chart_rounded,
        ),
        const SizedBox(height: 12),
        DashboardInsightsRow(
          lowStockItems: data.lowStockItems,
          activities: data.activities,
        ),
      ],
    );
  }
}
