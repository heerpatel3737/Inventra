import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../widgets/buttons/luxury_button.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        LuxuryButton(
          label: 'Add Product',
          icon: Icons.add_rounded,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
        ),
        LuxuryButton(
          label: 'Review Alerts',
          icon: Icons.warning_amber_outlined,
          outlined: true,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.inventoryAlerts),
        ),
        LuxuryButton(
          label: 'Open Scanner',
          icon: Icons.qr_code_scanner_outlined,
          outlined: true,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.scanner),
        ),
        LuxuryButton(
          label: 'Sync Status',
          icon: Icons.sync_rounded,
          outlined: true,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.offlineSync),
        ),
      ],
    );
  }
}
