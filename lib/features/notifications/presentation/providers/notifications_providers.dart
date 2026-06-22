import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/notification_model.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../data/notifications_repository.dart';
import 'notifications_notifier.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(databaseHelperProvider));
});

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return NotificationsNotifier(repository);
});

/// Syncs stock alerts whenever product inventory changes.
final notificationsInventorySyncProvider = Provider<void>((ref) {
  ref.listen(productsProvider, (previous, next) {
    next.whenData((products) {
      ref.read(notificationsProvider.notifier).syncStockAlerts(products);
    });
  });
});

final notificationCategoryFilterProvider = StateProvider<String>((ref) => 'All');

final filteredNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  final category = ref.watch(notificationCategoryFilterProvider);

  return notificationsAsync.maybeWhen(
    data: (notifications) {
      if (category == 'All') return notifications;
      if (category == 'Unread') return notifications.where((n) => !n.isRead).toList();
      return notifications.where((n) => n.category == category).toList();
    },
    orElse: () => <NotificationModel>[],
  );
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

final notificationsRefreshProvider = Provider<void Function()>((ref) {
  return () => ref.read(notificationsProvider.notifier).loadNotifications();
});

String formatNotificationTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
