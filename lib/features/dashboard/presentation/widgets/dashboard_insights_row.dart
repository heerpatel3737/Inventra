import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/activity_timeline_tile.dart';
import '../../../../shared/widgets/stock_alert_tile.dart';
import '../../../../widgets/cards/glass_panel.dart';
import '../../domain/dashboard_models.dart';

class DashboardInsightsRow extends StatelessWidget {
  final List<LowStockItem> lowStockItems;
  final List<ActivityItem> activities;

  const DashboardInsightsRow({
    super.key,
    required this.lowStockItems,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    final lowStockPanel = GlassPanel(
      padding: const EdgeInsets.all(AppSizes.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock Overview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Items requiring immediate attention',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.space16),
          ...lowStockItems.asMap().entries.map(
            (entry) => StockAlertTile(
              productName: entry.value.name,
              quantityLeft: entry.value.quantityLeft,
              isCritical: entry.value.quantityLeft <= 5,
            ),
          ),
        ],
      ),
    );

    final activityPanel = GlassPanel(
      padding: const EdgeInsets.all(AppSizes.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Latest operational events',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.space16),
          ...activities.asMap().entries.map(
            (entry) => ActivityTimelineTile(
              title: entry.value.title,
              timestamp: entry.value.timeAgo,
              icon: Icons.history_rounded,
              isLast: entry.key == activities.length - 1,
            ),
          ),
        ],
      ),
    );

    if (isCompact) {
      return Column(
        children: [
          lowStockPanel,
          const SizedBox(height: AppSizes.space16),
          activityPanel,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: lowStockPanel),
          const SizedBox(width: AppSizes.space16),
          Expanded(child: activityPanel),
        ],
      ),
    );
  }
}
