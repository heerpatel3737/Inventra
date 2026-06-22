import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/charts/chart_placeholder.dart';
import '../../widgets/layouts/editorial_header.dart';
import '../../widgets/layouts/luxury_scaffold.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LuxuryScaffold(
      route: AppRoutes.scanner,
      title: 'Scanner Studio',
      header: EditorialHeader(
        eyebrow: 'Capture Interface',
        title: 'Barcode & QR Intake',
        subtitle: 'High-confidence code capture with structured product mapping context.',
      ),
      children: [
        ChartPlaceholder(
          title: 'Scanner Viewport',
          subtitle: 'Live capture surface for barcode and QR recognition.',
          icon: Icons.qr_code_scanner_rounded,
          height: 260,
        ),
        SizedBox(height: 10),
        Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Last scanned code'), subtitle: Text('978020137962'))),
      ],
    );
  }
}

