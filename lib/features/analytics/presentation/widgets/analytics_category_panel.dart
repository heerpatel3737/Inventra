import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/analytics_providers.dart';

class AnalyticsCategoryPanel extends ConsumerWidget {
  const AnalyticsCategoryPanel({super.key});

  Color _getPaletteColor(int index) {
    final colors = [
      AppColors.accentGold,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      Colors.indigoAccent,
      Colors.purpleAccent,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distribution = ref.watch(categoryDistributionProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Distribution', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Portfolio composition and demand concentration.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            if (distribution.isEmpty)
              const SizedBox(
                height: 100,
                child: Center(child: Text('No category distribution available yet.')),
              )
            else
              _buildChartContent(context, distribution, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(
    BuildContext context,
    List<CategoryShare> distribution,
    bool isMobile,
  ) {
    final pieSections = distribution.map((entry) {
      final index = distribution.indexOf(entry);
      final color = _getPaletteColor(index);
      return PieChartSectionData(
        value: entry.share,
        color: color,
        title: '${entry.share.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    Widget buildCategoryList() {
      return Column(
        children: distribution.map((entry) {
          final index = distribution.indexOf(entry);
          final color = _getPaletteColor(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.category, style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text('${entry.count} SKUs • ${entry.share.toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: entry.share / 100,
                    minHeight: 6,
                    color: color,
                    backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 18),
          buildCategoryList(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: buildCategoryList(),
        ),
      ],
    );
  }
}
