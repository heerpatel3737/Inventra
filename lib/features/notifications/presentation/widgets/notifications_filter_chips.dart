import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notifications_providers.dart';

class NotificationsFilterChips extends ConsumerWidget {
  const NotificationsFilterChips({super.key});

  static const _filters = ['All', 'Unread', 'Stock Alert', 'Order Update', 'Purchase', 'System Warning'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(notificationCategoryFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters.map((filter) {
        return FilterChip(
          label: Text(filter),
          selected: selected == filter,
          onSelected: (_) => ref.read(notificationCategoryFilterProvider.notifier).state = filter,
        );
      }).toList(),
    );
  }
}
