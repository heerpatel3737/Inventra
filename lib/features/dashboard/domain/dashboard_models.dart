import 'package:flutter/material.dart';

/// One KPI tile shown on the dashboard grid.
class DashboardMetric {
  final String id;
  final String label;
  final String value;
  final String caption;
  final IconData icon;

  const DashboardMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
  });

  DashboardMetric copyWith({String? value, String? caption}) {
    return DashboardMetric(
      id: id,
      label: label,
      value: value ?? this.value,
      caption: caption ?? this.caption,
      icon: icon,
    );
  }
}

class LowStockItem {
  final String name;
  final int quantityLeft;

  const LowStockItem({required this.name, required this.quantityLeft});
}

class ActivityItem {
  final String title;
  final String timeAgo;

  const ActivityItem({required this.title, required this.timeAgo});
}

/// Full dashboard payload used by the UI layer.
class DashboardData {
  final List<DashboardMetric> metrics;
  final List<LowStockItem> lowStockItems;
  final List<ActivityItem> activities;

  const DashboardData({
    required this.metrics,
    required this.lowStockItems,
    required this.activities,
  });

  /// Updates only the product metric when inventory count changes elsewhere.
  DashboardData withLiveCounts({
    required int productCount,
    required int lowStockCount,
    required int supplierCount,
    required double monthlyRevenue,
  }) {
    final updatedMetrics = metrics.map((metric) {
      if (metric.id == 'products') {
        return metric.copyWith(
          value: _formatCount(productCount),
          caption: 'Live catalog units',
        );
      }
      if (metric.id == 'revenue') {
        return metric.copyWith(
          value: _formatCurrency(monthlyRevenue),
          caption: 'Live sales revenue total',
        );
      }
      if (metric.id == 'suppliers') {
        return metric.copyWith(
          value: _formatCount(supplierCount),
          caption: 'Active supplier partners',
        );
      }
      if (metric.id == 'alerts') {
        return metric.copyWith(
          value: _formatCount(lowStockCount),
          caption: 'Items at or below threshold',
        );
      }
      return metric;
    }).toList();

    return DashboardData(
      metrics: updatedMetrics,
      lowStockItems: lowStockItems,
      activities: activities,
    );
  }

  static String _formatCurrency(double value) {
    if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';
    return '\$${value.toStringAsFixed(0)}';
  }

  static String _formatCount(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      if (i > 0 && positionFromEnd % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }
}
