import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_timeline_card.dart';
import '../widgets/notifications_filter_chips.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationsInventorySyncProvider);

    final notificationsAsync = ref.watch(notificationsProvider);
    final filtered = ref.watch(filteredNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final refresh = ref.read(notificationsRefreshProvider);

    return LuxuryScaffold(
      route: AppRoutes.notifications,
      title: 'Notifications',
      header: EditorialHeader(
        eyebrow: 'System Signals',
        title: 'Notification Timeline',
        subtitle: unreadCount == 0
            ? 'You are all caught up.'
            : '$unreadCount unread notifications require attention.',
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: LuxuryButton(
                label: 'Mark All Read',
                icon: Icons.done_all_rounded,
                outlined: true,
                onPressed: unreadCount == 0
                    ? null
                    : () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const NotificationsFilterChips(),
        const SizedBox(height: 14),
        notificationsAsync.when(
          loading: () => const AppLoadingView(message: 'Loading notifications...'),
          error: (error, _) => AppErrorView(
            message: 'Unable to load notifications.\n$error',
            onRetry: refresh,
          ),
          data: (_) {
            if (filtered.isEmpty) {
              return const AppEmptyView(
                title: 'No notifications',
                subtitle: 'No alerts match your current filter.',
                icon: Icons.notifications_none_rounded,
              );
            }

            return Column(
              children: filtered
                  .map(
                    (notification) => NotificationTimelineCard(
                      notification: notification,
                      onTap: () => ref.read(notificationsProvider.notifier).markAsRead(notification.id),
                      onDismiss: () => ref.read(notificationsProvider.notifier).deleteNotification(notification.id),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
