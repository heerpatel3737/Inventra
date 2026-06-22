import 'package:flutter/material.dart';

import '../../../data/database/database_helper.dart';
import '../domain/dashboard_models.dart';

/// Data source for dashboard.
/// Reads live data from SQLite — no mock/hardcoded values.
class DashboardRepository {
  DashboardRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<DashboardData> fetchDashboard() async {
    // Fetch real data from SQLite
    final products = await _databaseHelper.getProducts();
    final sales = await _databaseHelper.getSales();
    final purchases = await _databaseHelper.getPurchases();
    final suppliers = await _databaseHelper.getSuppliers();

    // --- Metrics ---
    final productCount = products.length;
    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.amount);
    final supplierCount = suppliers.length;
    final lowStockCount = products.where((p) => p.stock <= 5).length;

    final metrics = [
      DashboardMetric(
        id: 'products',
        label: 'Total Products',
        value: _formatCount(productCount),
        caption: 'Live catalog units',
        icon: Icons.inventory_2_outlined,
      ),
      DashboardMetric(
        id: 'revenue',
        label: 'Total Revenue',
        value: _formatCurrency(totalRevenue),
        caption: '${sales.length} transactions recorded',
        icon: Icons.auto_graph,
      ),
      DashboardMetric(
        id: 'suppliers',
        label: 'Supplier Network',
        value: _formatCount(supplierCount),
        caption: 'Active supplier partners',
        icon: Icons.groups_2_outlined,
      ),
      DashboardMetric(
        id: 'alerts',
        label: 'Risk Alerts',
        value: _formatCount(lowStockCount),
        caption: 'Items at or below threshold',
        icon: Icons.warning_amber_outlined,
      ),
    ];

    // --- Low Stock Items (from real product data) ---
    final lowStockProducts = products.where((p) => p.stock <= 10).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
    final lowStockItems = lowStockProducts
        .take(5)
        .map((p) => LowStockItem(name: p.name, quantityLeft: p.stock))
        .toList();

    // --- Recent Activity (from real sales + purchases) ---
    final activities = <ActivityItem>[];

    for (final sale in sales.take(3)) {
      activities.add(ActivityItem(
        title: 'Sale to ${sale.clientName} — \$${sale.amount.toStringAsFixed(0)}',
        timeAgo: _timeAgo(sale.createdAt),
      ));
    }
    for (final purchase in purchases.take(3)) {
      activities.add(ActivityItem(
        title: 'Purchase from ${purchase.supplierName} — \$${purchase.amount.toStringAsFixed(0)}',
        timeAgo: _timeAgo(purchase.createdAt),
      ));
    }

    // Sort activities by recency (most recent first based on timeAgo text)
    // Since sales/purchases are already sorted by createdAt DESC, just interleave
    activities.sort((a, b) => a.timeAgo.compareTo(b.timeAgo));

    // If no activity data exists, show a helpful empty state
    if (activities.isEmpty) {
      activities.add(const ActivityItem(
        title: 'No recent activity',
        timeAgo: 'Add sales or purchases to see activity here',
      ));
    }

    return DashboardData(
      metrics: metrics,
      lowStockItems: lowStockItems.isEmpty
          ? const [LowStockItem(name: 'All items above threshold', quantityLeft: 99)]
          : lowStockItems,
      activities: activities.take(5).toList(),
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
      if (i > 0 && positionFromEnd % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  static String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }
}
