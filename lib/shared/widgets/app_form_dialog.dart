import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// Reusable modal shell for create/edit forms.
Future<bool?> showAppFormDialog({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      );
    },
  );
}
