import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PurchaseStatusChip extends StatelessWidget {
  final String status;

  const PurchaseStatusChip({super.key, required this.status});

  Color _color(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'received':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.danger;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
