import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/notification_model.dart';
import '../../../../models/product_model.dart';
import '../../../../services/notification_service.dart';
import '../../data/notifications_repository.dart';

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  final NotificationsRepository _repository;

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchNotifications);
  }

  /// Keeps inventory low-stock alerts in sync with product state and triggers push notifications.
  Future<void> syncStockAlerts(List<ProductModel> products) async {
    final current = state.value ?? <NotificationModel>[];
    final existingStock = {
      for (final notification in current.where((n) => n.id.startsWith('stock-')))
        notification.id: notification,
    };

    final stockAlerts = <NotificationModel>[];

    for (final product in products.where((p) => p.stock <= 5)) {
      final id = 'stock-${product.id}';
      final existing = existingStock[id];

      // Trigger local status bar alert if it is newly low-stock
      if (existing == null) {
        NotificationService.instance.showLocalNotification(
          title: 'Low Stock Alert 🚨',
          body: '${product.name} is running low (only ${product.stock} left).',
        );
      }

      stockAlerts.add(NotificationModel(
        id: id,
        category: 'Stock Alert',
        title: '${product.name} below threshold',
        message: 'Only ${product.stock} units remaining • reorder recommended',
        createdAt: existing?.createdAt ?? DateTime.now(),
        isRead: existing?.isRead ?? false,
      ));
    }

    try {
      await _repository.replaceStockNotifications(stockAlerts);
    } catch (_) {}
    
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      await loadNotifications();
    } catch (e) {
      final current = state.value ?? <NotificationModel>[];
      state = AsyncValue.data(
        [
          for (final notification in current)
            if (notification.id == id) notification.copyWith(isRead: true) else notification,
        ],
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      final current = state.value ?? <NotificationModel>[];
      state = AsyncValue.data(
        current.map((notification) => notification.copyWith(isRead: true)).toList(),
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      await loadNotifications();
    } catch (e) {
      final current = state.value ?? <NotificationModel>[];
      state = AsyncValue.data(
        current.where((notification) => notification.id != id).toList(),
      );
    }
  }
}
