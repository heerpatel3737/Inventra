import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:common_inventory_management_software/app.dart';

void main() {
  testWidgets('Inventory app builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: InventoryApp(),
      ),
    );

    expect(find.byType(InventoryApp), findsOneWidget);
    
    // Drain splash screen redirect timer
    await tester.pump(const Duration(seconds: 5));
  });
}
