import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:common_inventory_management_software/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

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
