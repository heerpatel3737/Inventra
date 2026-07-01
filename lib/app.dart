import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/categories/presentation/screens/categories_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/suppliers/presentation/screens/suppliers_screen.dart';
import 'data/models/product_model.dart';
import 'features/products/presentation/screens/add_product_screen.dart';
import 'features/purchases/presentation/screens/purchases_screen.dart';
import 'features/sales/presentation/screens/sales_screen.dart';
import 'features/products/presentation/screens/product_details_screen.dart';
import 'features/products/presentation/screens/products_screen.dart';
import 'features/analytics/presentation/screens/analytics_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/auth_gate.dart';
import 'features/inventory_alerts/presentation/screens/inventory_alerts_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/products/scanner_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/settings/presentation/screens/offline_sync_screen.dart';
import 'features/settings/presentation/screens/profile_screen.dart';
import 'features/settings/presentation/screens/role_access_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'features/notifications/presentation/providers/notifications_providers.dart';
import 'shared/providers/theme_mode_provider.dart';
import 'providers/user_session_provider.dart';

class InventoryApp extends ConsumerWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationsInventorySyncProvider);
    ref.watch(userSessionProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Common Inventory Management Software',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.authGate: (_) => const AuthGate(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.products: (_) => const ProductsScreen(),
        AppRoutes.addProduct: (context) {
          final product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
          return AddProductScreen(productToEdit: product);
        },
        AppRoutes.productDetails: (_) => const ProductDetailsScreen(),
        AppRoutes.categories: (_) => const CategoriesScreen(),
        AppRoutes.suppliers: (_) => const SuppliersScreen(),
        AppRoutes.sales: (_) => const SalesScreen(),
        AppRoutes.purchases: (_) => const PurchasesScreen(),
        AppRoutes.reports: (_) => const ReportsScreen(),
        AppRoutes.analytics: (_) => const AnalyticsScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.roleAccess: (_) => const RoleAccessScreen(),
        AppRoutes.inventoryAlerts: (_) => const InventoryAlertsScreen(),
        AppRoutes.scanner: (_) => const ScannerScreen(),
        AppRoutes.offlineSync: (_) => const OfflineSyncScreen(),
      },
    );
  }
}
