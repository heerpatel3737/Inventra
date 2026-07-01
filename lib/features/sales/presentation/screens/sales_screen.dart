import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/sales_providers.dart';
import '../widgets/sale_form_dialog.dart';
import '../widgets/sales_filter_chips.dart';
import '../widgets/sales_metrics_row.dart';
import '../widgets/sales_transactions_table.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);
    final refreshSales = ref.read(salesRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.sales,
      title: 'Sales',
      header: const EditorialHeader(
        eyebrow: 'Revenue Architecture',
        title: 'Sales Intelligence',
        subtitle: 'Track revenue, order flow, and transaction quality in real time.',
      ),
      children: [
        LuxuryButton(
          label: 'Record Sale',
          icon: Icons.add_rounded,
          onPressed: () => openSaleFormDialog(context),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search orders, clients, status...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) => ref.read(salesSearchQueryProvider.notifier).state = value,
        ),
        const SizedBox(height: 12),
        const SalesFilterChips(),
        const SizedBox(height: 14),
        salesAsync.when(
          loading: () => const AppLoadingView(message: 'Loading sales data...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load sales.\n$error',
            onRetry: refreshSales,
          ),
          data: (_) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SalesMetricsRow(),
              SizedBox(height: 14),
              _OrderMomentumChart(),
              SizedBox(height: 12),
              SalesTransactionsTable(),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderMomentumChart extends ConsumerWidget {
  const _OrderMomentumChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(monthlyTrendProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Momentum', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Monthly revenue and order trend performance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (points.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(child: Text('No order momentum data available yet.')),
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
                              formatSalesCurrency(spot.y),
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
