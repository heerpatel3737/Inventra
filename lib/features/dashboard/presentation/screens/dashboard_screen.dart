import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../../../../widgets/layouts/luxury_search_bar.dart';
import '../../domain/dashboard_models.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_insights_row.dart';
import '../widgets/dashboard_metrics_grid.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../../products/presentation/providers/products_providers.dart';

/// Dashboard entry screen.
/// Uses Riverpod so KPI cards update when shared inventory state changes.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final query = ref.read(productSearchQueryProvider);
    _searchController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final refreshDashboard = ref.read(dashboardRefreshProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);

    // Sync external query modifications back to text field
    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
    }

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
          controller: _searchController,
          onChanged: (value) {
            ref.read(productSearchQueryProvider.notifier).state = value;
          },
          onSubmitted: (value) {
            ref.read(productSearchQueryProvider.notifier).state = value;
            Navigator.pushNamed(context, AppRoutes.products);
          },
          trailing: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.products);
            },
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
          data: (data) {
            final query = searchQuery.trim().toLowerCase();
            final filteredData = query.isEmpty
                ? data
                : DashboardData(
                    metrics: data.metrics,
                    lowStockItems: data.lowStockItems
                        .where((item) => item.name.toLowerCase().contains(query))
                        .toList(),
                    activities: data.activities
                        .where((act) => act.title.toLowerCase().contains(query))
                        .toList(),
                  );
            return _DashboardContent(data: filteredData);
          },
        ),
      ],
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final DashboardData data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardMetricsGrid(metrics: data.metrics),
        const SizedBox(height: 16),
        const DashboardQuickActions(),
        const SizedBox(height: 18),
        const _SalesFlowChart(),
        const SizedBox(height: 12),
        DashboardInsightsRow(
          lowStockItems: data.lowStockItems.isEmpty
              ? const [LowStockItem(name: 'All items above threshold', quantityLeft: 99)]
              : data.lowStockItems,
          activities: data.activities,
        ),
      ],
    );
  }
}

class _SalesFlowChart extends ConsumerWidget {
  const _SalesFlowChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(monthlyTrendProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales Flow Narrative', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Monthly performance curve with trend intelligence and forecast markers.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (points.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(child: Text('No sales trend data available yet.')),
              )
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < points.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  points[index].label,
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 32,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(points.length, (index) {
                          return FlSpot(index.toDouble(), points[index].revenue);
                        }),
                        isCurved: true,
                        color: AppColors.accentGold,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 6,
                            color: AppColors.accentGold,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.accentGold.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.black.withValues(alpha: 0.8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              formatAnalyticsCurrency(spot.y),
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
