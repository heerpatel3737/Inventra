import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StockAlertTile extends StatelessWidget {
  final String productName;
  final int quantityLeft;
  final bool isCritical;

  const StockAlertTile({
    super.key,
    required this.productName,
    required this.quantityLeft,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isCritical ? AppColors.danger : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              productName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            '$quantityLeft left',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
