import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/category_model.dart';
import '../../models/notification_model.dart';
import '../../models/product_model.dart';
import '../../models/purchase_model.dart';
import '../../models/role_model.dart';
import '../../models/sales_model.dart';
import '../../models/supplier_model.dart';
import '../../models/sync_status_model.dart';
import '../../models/user_profile_model.dart';
import '../../models/sync_queue_item.dart';

/// Web/Chrome storage fallback. SQLite is not available in Flutter web.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _productsKey = 'inventory_products_v2';
  static const _categoriesKey = 'inventory_categories_v2';
  static const _suppliersKey = 'inventory_suppliers_v2';
  static const _salesKey = 'inventory_sales_v2';
  static const _purchasesKey = 'inventory_purchases_v2';
  static const _notificationsKey = 'inventory_notifications_v2';
  static const _rolesKey = 'inventory_roles_v2';
  static const _profileKey = 'inventory_profile_v2';
  static const _syncStatusKey = 'inventory_sync_status_v2';
  static const _syncQueueKey = 'inventory_sync_queue_v2';

  final List<ProductModel> _products = [];
  final List<CategoryModel> _categories = [];
  final List<SupplierModel> _suppliers = [];
  final List<SalesModel> _sales = [];
  final List<PurchaseModel> _purchases = [];
  final List<NotificationModel> _notifications = [];
  final List<RoleModel> _roles = [];
  final List<SyncQueueItem> _syncQueue = [];
  UserProfileModel? _profile;
  SyncStatusModel _syncStatus = const SyncStatusModel();

  bool _ready = false;
  int _nextProductId = 1;

  Future<void> ensureInitialized() async {
    if (_ready) return;

    final prefs = await SharedPreferences.getInstance();
    _products
      ..clear()
      ..addAll(_readList(prefs, _productsKey, ProductModel.fromMap));
    _categories
      ..clear()
      ..addAll(_readList(prefs, _categoriesKey, CategoryModel.fromMap));
    _suppliers
      ..clear()
      ..addAll(_readList(prefs, _suppliersKey, SupplierModel.fromMap));
    _sales
      ..clear()
      ..addAll(_readList(prefs, _salesKey, SalesModel.fromMap));
    _purchases
      ..clear()
      ..addAll(_readList(prefs, _purchasesKey, PurchaseModel.fromMap));
    _notifications
      ..clear()
      ..addAll(_readList(prefs, _notificationsKey, NotificationModel.fromMap));
    _roles
      ..clear()
      ..addAll(_readList(prefs, _rolesKey, RoleModel.fromMap));

    final profileRaw = prefs.getString(_profileKey);
    if (profileRaw != null) {
      _profile = UserProfileModel.fromMap(_decodeMap(profileRaw));
    }
    final syncRaw = prefs.getString(_syncStatusKey);
    if (syncRaw != null) {
      _syncStatus = SyncStatusModel.fromMap(_decodeMap(syncRaw));
    }
 
    _syncQueue
      ..clear()
      ..addAll(_readList(prefs, _syncQueueKey, SyncQueueItem.fromMap));

    _nextProductId = _products.fold<int>(
      1,
      (maxId, product) => product.id != null && product.id! >= maxId ? product.id! + 1 : maxId,
    );
    _ready = true;
  }

  List<T> _readList<T>(
    SharedPreferences prefs,
    String key,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return <T>[];
    return (jsonDecode(raw) as List<dynamic>)
        .map((row) => fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Map<String, dynamic> _decodeMap(String raw) {
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> _persistList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toMap,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items.map(toMap).toList()));
  }

  Future<int> insertProduct(ProductModel product) async {
    await ensureInitialized();
    final id = _nextProductId++;
    _products.add(product.copyWith(id: id));
    await _persistList(_productsKey, _products, (product) => product.toMap());
    return id;
  }

  Future<List<ProductModel>> getProducts() async {
    await ensureInitialized();
    return ([..._products]..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<int> updateProduct(ProductModel product) async {
    await ensureInitialized();
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index == -1) return 0;
    _products[index] = product;
    await _persistList(_productsKey, _products, (product) => product.toMap());
    return 1;
  }

  Future<int> deleteProduct(int id) async {
    await ensureInitialized();
    final before = _products.length;
    _products.removeWhere((product) => product.id == id);
    await _persistList(_productsKey, _products, (product) => product.toMap());
    return before - _products.length;
  }

  Future<List<CategoryModel>> getCategories() async {
    await ensureInitialized();
    return ([..._categories]..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<void> upsertCategory(CategoryModel category) async {
    await ensureInitialized();
    _categories.removeWhere((item) => item.id == category.id);
    _categories.add(category);
    await _persistList(_categoriesKey, _categories, (category) => category.toMap());
  }

  Future<int> deleteCategory(String id) async {
    await ensureInitialized();
    final before = _categories.length;
    _categories.removeWhere((category) => category.id == id);
    await _persistList(_categoriesKey, _categories, (category) => category.toMap());
    return before - _categories.length;
  }

  Future<List<SupplierModel>> getSuppliers() async {
    await ensureInitialized();
    return ([..._suppliers]..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<void> upsertSupplier(SupplierModel supplier) async {
    await ensureInitialized();
    _suppliers.removeWhere((item) => item.id == supplier.id);
    _suppliers.add(supplier);
    await _persistList(_suppliersKey, _suppliers, (supplier) => supplier.toMap());
  }

  Future<int> deleteSupplier(String id) async {
    await ensureInitialized();
    final before = _suppliers.length;
    _suppliers.removeWhere((supplier) => supplier.id == id);
    await _persistList(_suppliersKey, _suppliers, (supplier) => supplier.toMap());
    return before - _suppliers.length;
  }

  Future<List<SalesModel>> getSales() async {
    await ensureInitialized();
    return ([..._sales]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> insertSale(SalesModel sale) async {
    await ensureInitialized();
    final index = _products.indexWhere((product) => product.stock > 0);
    if (index == -1) {
      throw Exception('Sale blocked: no stock is available.');
    }
    _products[index] = _products[index].copyWith(stock: _products[index].stock - 1);
    _sales.add(sale);
    await _persistList(_productsKey, _products, (product) => product.toMap());
    await _persistList(_salesKey, _sales, (sale) => sale.toMap());
  }

  Future<int> deleteSale(String id) async {
    await ensureInitialized();
    final before = _sales.length;
    _sales.removeWhere((sale) => sale.id == id);
    if (_products.isNotEmpty && before != _sales.length) {
      _products.first = _products.first.copyWith(stock: _products.first.stock + 1);
      await _persistList(_productsKey, _products, (product) => product.toMap());
    }
    await _persistList(_salesKey, _sales, (sale) => sale.toMap());
    return before - _sales.length;
  }

  Future<List<PurchaseModel>> getPurchases() async {
    await ensureInitialized();
    return ([..._purchases]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> insertPurchase(PurchaseModel purchase) async {
    await ensureInitialized();
    final index = _products.indexWhere((product) => product.supplier == purchase.supplierName);
    if (index != -1) {
      _products[index] = _products[index].copyWith(stock: _products[index].stock + 1);
      await _persistList(_productsKey, _products, (product) => product.toMap());
    }
    _purchases.add(purchase);
    await _persistList(_purchasesKey, _purchases, (purchase) => purchase.toMap());
  }

  Future<int> deletePurchase(String id) async {
    await ensureInitialized();
    final before = _purchases.length;
    _purchases.removeWhere((purchase) => purchase.id == id);
    await _persistList(_purchasesKey, _purchases, (purchase) => purchase.toMap());
    return before - _purchases.length;
  }

  Future<List<NotificationModel>> getNotifications() async {
    await ensureInitialized();
    return ([..._notifications]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> upsertNotification(NotificationModel notification) async {
    await ensureInitialized();
    _notifications.removeWhere((item) => item.id == notification.id);
    _notifications.add(notification);
    await _persistList(_notificationsKey, _notifications, (notification) => notification.toMap());
  }

  Future<void> replaceStockNotifications(List<NotificationModel> notifications) async {
    await ensureInitialized();
    _notifications.removeWhere((notification) => notification.id.startsWith('stock-'));
    _notifications.addAll(notifications);
    await _persistList(_notificationsKey, _notifications, (notification) => notification.toMap());
  }

  Future<void> markNotificationAsRead(String id) async {
    await ensureInitialized();
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _persistList(_notificationsKey, _notifications, (notification) => notification.toMap());
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    await ensureInitialized();
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _persistList(_notificationsKey, _notifications, (notification) => notification.toMap());
  }

  Future<int> deleteNotification(String id) async {
    await ensureInitialized();
    final before = _notifications.length;
    _notifications.removeWhere((notification) => notification.id == id);
    await _persistList(_notificationsKey, _notifications, (notification) => notification.toMap());
    return before - _notifications.length;
  }

  Future<List<RoleModel>> getRoles() async {
    await ensureInitialized();
    return [..._roles];
  }

  Future<void> upsertRole(RoleModel role) async {
    await ensureInitialized();
    _roles.removeWhere((item) => item.id == role.id);
    _roles.add(role);
    await _persistList(_rolesKey, _roles, (role) => role.toMap());
  }

  Future<UserProfileModel> getProfile() async {
    await ensureInitialized();
    return _profile ?? const UserProfileModel(name: '', email: '', role: '', phone: '', department: '');
  }

  Future<void> upsertProfile(UserProfileModel profile) async {
    await ensureInitialized();
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  Future<SyncStatusModel> getSyncStatus() async {
    await ensureInitialized();
    return _syncStatus;
  }

  Future<void> upsertSyncStatus(SyncStatusModel status) async {
    await ensureInitialized();
    _syncStatus = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_syncStatusKey, jsonEncode(status.toMap()));
  }

  Future<int> insertQueueItem(SyncQueueItem item) async {
    await ensureInitialized();
    final id = _syncQueue.length + 1;
    _syncQueue.add(SyncQueueItem(
      id: id,
      collection: item.collection,
      action: item.action,
      recordId: item.recordId,
      data: item.data,
      createdAt: item.createdAt,
    ));
    await _persistList(_syncQueueKey, _syncQueue, (q) => q.toMap());
    return id;
  }

  Future<List<SyncQueueItem>> getQueueItems() async {
    await ensureInitialized();
    return [..._syncQueue];
  }

  Future<int> deleteQueueItem(int id) async {
    await ensureInitialized();
    final before = _syncQueue.length;
    _syncQueue.removeWhere((item) => item.id == id);
    await _persistList(_syncQueueKey, _syncQueue, (q) => q.toMap());
    return before - _syncQueue.length;
  }

  Future<void> close() async {
    _ready = false;
  }
}
