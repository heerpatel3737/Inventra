// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';

// import '../../models/category_model.dart';
// import '../../models/notification_model.dart';
// import '../../models/product_model.dart';
// import '../../models/purchase_model.dart';
// import '../../models/role_model.dart';
// import '../../models/sales_model.dart';
// import '../../models/supplier_model.dart';
// import '../../models/sync_status_model.dart';
// import '../../models/user_profile_model.dart';
// import '../../models/sync_queue_item.dart';

// /// Web/Chrome storage fallback. SQLite is not available in Flutter web.
// class DatabaseHelper {
//   DatabaseHelper._();

//   static final DatabaseHelper instance = DatabaseHelper._();

//   static const _productsPrefix = 'inventory_products_v3_';
//   static const _categoriesPrefix = 'inventory_categories_v3_';
//   static const _suppliersPrefix = 'inventory_suppliers_v3_';
//   static const _salesPrefix = 'inventory_sales_v3_';
//   static const _purchasesPrefix = 'inventory_purchases_v3_';
//   static const _notificationsPrefix = 'inventory_notifications_v3_';
//   static const _rolesKey = 'inventory_roles_v2';
//   static const _profilePrefix = 'inventory_profile_v3_';
//   static const _syncStatusPrefix = 'inventory_sync_status_v3_';
//   static const _syncQueuePrefix = 'inventory_sync_queue_v3_';

//   final List<ProductModel> _products = [];
//   final List<CategoryModel> _categories = [];
//   final List<SupplierModel> _suppliers = [];
//   final List<SalesModel> _sales = [];
//   final List<PurchaseModel> _purchases = [];
//   final List<NotificationModel> _notifications = [];
//   final List<RoleModel> _roles = [];
//   final List<SyncQueueItem> _syncQueue = [];
//   UserProfileModel? _profile;
//   SyncStatusModel _syncStatus = const SyncStatusModel();

//   bool _ready = false;
//   int _nextProductId = 1;
//   String? _currentUserId;
//   String? _loadedUserId;

//   String? get currentUserId => _currentUserId;

//   void setCurrentUserId(String? uid) {
//     if (_currentUserId == uid) return;
//     _currentUserId = uid;
//     _ready = false;
//   }

//   String _requireUserId() {
//     final uid = _currentUserId;
//     if (uid == null || uid.isEmpty) {
//       throw Exception('No authenticated user. Sign in to access inventory data.');
//     }
//     return uid;
//   }

//   String _scopedKey(String prefix, String uid) => '$prefix$uid';

//   String? _readUserId() {
//     final uid = _currentUserId;
//     if (uid == null || uid.isEmpty) return null;
//     return uid;
//   }

//   Future<void> ensureInitialized() async {
//     final uid = _readUserId();
//     if (uid == null) return;
//     if (_ready && _loadedUserId == uid) return;

//     final prefs = await SharedPreferences.getInstance();
//     _products
//       ..clear()
//       ..addAll(_readList(prefs, _scopedKey(_productsPrefix, uid), ProductModel.fromMap));
//     _categories
//       ..clear()
//       ..addAll(_readList(prefs, _scopedKey(_categoriesPrefix, uid), CategoryModel.fromMap));
//     _suppliers
//       ..clear()
//       ..addAll(_readList(prefs, _scopedKey(_suppliersPrefix, uid), SupplierModel.fromMap));
//     _sales
//       ..clear()
//       ..addAll(_readList(prefs, _scopedKey(_salesPrefix, uid), SalesModel.fromMap));
//     _purchases
//       ..clear()
//       ..addAll(_readList(prefs, _scopedKey(_purchasesPrefix, uid), PurchaseModel.fromMap));
//     _notifications
//       ..clear()
//       ..addAll(_readList(prefs, _scopedKey(_notificationsPrefix, uid), NotificationModel.fromMap));
//     _roles
//       ..clear()
//       ..addAll(_readList(prefs, _rolesKey, RoleModel.fromMap));

//     final profileRaw = prefs.getString(_scopedKey(_profilePrefix, uid));
//     _profile = profileRaw != null
//         ? UserProfileModel.fromMap(_decodeMap(profileRaw))
//         : null;
//     final syncRaw = prefs.getString(_scopedKey(_syncStatusPrefix, uid));
//     _syncStatus = syncRaw != null
//         ? SyncStatusModel.fromMap(_decodeMap(syncRaw))
//         : const SyncStatusModel();

//     _syncQueue
//       ..clear()
//       ..addAll(_readList(prefs, _scopedKey(_syncQueuePrefix, uid), SyncQueueItem.fromMap));

//     _nextProductId = _products.fold<int>(
//       1,
//       (maxId, product) => product.id != null && product.id! >= maxId ? product.id! + 1 : maxId,
//     );
//     _loadedUserId = uid;
//     _ready = true;
//   }

//   List<T> _readList<T>(
//     SharedPreferences prefs,
//     String key,
//     T Function(Map<String, dynamic>) fromMap,
//   ) {
//     final raw = prefs.getString(key);
//     if (raw == null || raw.isEmpty) return <T>[];
//     return (jsonDecode(raw) as List<dynamic>)
//         .map((row) => fromMap(Map<String, dynamic>.from(row as Map)))
//         .toList();
//   }

//   Map<String, dynamic> _decodeMap(String raw) {
//     return Map<String, dynamic>.from(jsonDecode(raw) as Map);
//   }

//   Future<void> _persistList<T>(
//     String key,
//     List<T> items,
//     Map<String, dynamic> Function(T) toMap,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(key, jsonEncode(items.map(toMap).toList()));
//   }

//   Future<int> insertProduct(ProductModel product) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final id = _nextProductId++;
//     _products.add(product.copyWith(id: id));
//     await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
//     return id;
//   }

//   Future<List<ProductModel>> getProducts() async {
//     if (_readUserId() == null) return [];
//     await ensureInitialized();
//     return ([..._products]..sort((a, b) => a.name.compareTo(b.name)));
//   }

//   Future<int> updateProduct(ProductModel product) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final index = _products.indexWhere((item) => item.id == product.id);
//     if (index == -1) return 0;
//     _products[index] = product;
//     await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
//     return 1;
//   }

//   Future<int> deleteProduct(int id) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final before = _products.length;
//     _products.removeWhere((product) => product.id == id);
//     await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
//     return before - _products.length;
//   }

//   Future<List<CategoryModel>> getCategories() async {
//     if (_readUserId() == null) return [];
//     await ensureInitialized();
//     return ([..._categories]..sort((a, b) => a.name.compareTo(b.name)));
//   }

//   Future<void> upsertCategory(CategoryModel category) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     _categories.removeWhere((item) => item.id == category.id);
//     _categories.add(category);
//     await _persistList(_scopedKey(_categoriesPrefix, uid), _categories, (c) => c.toMap());
//   }

//   Future<int> deleteCategory(String id) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final before = _categories.length;
//     _categories.removeWhere((category) => category.id == id);
//     await _persistList(_scopedKey(_categoriesPrefix, uid), _categories, (c) => c.toMap());
//     return before - _categories.length;
//   }

//   Future<List<SupplierModel>> getSuppliers() async {
//     if (_readUserId() == null) return [];
//     await ensureInitialized();
//     return ([..._suppliers]..sort((a, b) => a.name.compareTo(b.name)));
//   }

//   Future<void> upsertSupplier(SupplierModel supplier) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     _suppliers.removeWhere((item) => item.id == supplier.id);
//     _suppliers.add(supplier);
//     await _persistList(_scopedKey(_suppliersPrefix, uid), _suppliers, (s) => s.toMap());
//   }

//   Future<int> deleteSupplier(String id) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final before = _suppliers.length;
//     _suppliers.removeWhere((supplier) => supplier.id == id);
//     await _persistList(_scopedKey(_suppliersPrefix, uid), _suppliers, (s) => s.toMap());
//     return before - _suppliers.length;
//   }

//   Future<List<SalesModel>> getSales() async {
//     if (_readUserId() == null) return [];
//     await ensureInitialized();
//     return ([..._sales]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
//   }

//   Future<void> insertSale(SalesModel sale) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final index = _products.indexWhere((product) => product.stock > 0);
//     if (index == -1) {
//       throw Exception('Sale blocked: no stock is available.');
//     }
//     _products[index] = _products[index].copyWith(stock: _products[index].stock - 1);
//     _sales.add(sale);
//     await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
//     await _persistList(_scopedKey(_salesPrefix, uid), _sales, (s) => s.toMap());
//   }

//   Future<void> upsertSale(SalesModel sale) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     _sales.removeWhere((item) => item.id == sale.id);
//     _sales.add(sale);
//     await _persistList(_scopedKey(_salesPrefix, uid), _sales, (s) => s.toMap());
//   }

//   Future<int> deleteSale(String id) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final before = _sales.length;
//     _sales.removeWhere((sale) => sale.id == id);
//     if (_products.isNotEmpty && before != _sales.length) {
//       _products.first = _products.first.copyWith(stock: _products.first.stock + 1);
//       await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
//     }
//     await _persistList(_scopedKey(_salesPrefix, uid), _sales, (s) => s.toMap());
//     return before - _sales.length;
//   }

//   Future<List<PurchaseModel>> getPurchases() async {
//     if (_readUserId() == null) return [];
//     await ensureInitialized();
//     return ([..._purchases]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
//   }

//   Future<void> insertPurchase(PurchaseModel purchase) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final index = _products.indexWhere((product) => product.supplier == purchase.supplierName);
//     if (index != -1) {
//       _products[index] = _products[index].copyWith(stock: _products[index].stock + 1);
//       await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
//     }
//     _purchases.add(purchase);
//     await _persistList(_scopedKey(_purchasesPrefix, uid), _purchases, (p) => p.toMap());
//   }

//   Future<void> upsertPurchase(PurchaseModel purchase) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     _purchases.removeWhere((item) => item.id == purchase.id);
//     _purchases.add(purchase);
//     await _persistList(_scopedKey(_purchasesPrefix, uid), _purchases, (p) => p.toMap());
//   }

//   Future<int> deletePurchase(String id) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final before = _purchases.length;
//     _purchases.removeWhere((purchase) => purchase.id == id);
//     await _persistList(_scopedKey(_purchasesPrefix, uid), _purchases, (p) => p.toMap());
//     return before - _purchases.length;
//   }

//   Future<List<NotificationModel>> getNotifications() async {
//     await ensureInitialized();
//     return ([..._notifications]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
//   }

//   Future<void> upsertNotification(NotificationModel notification) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     _notifications.removeWhere((item) => item.id == notification.id);
//     _notifications.add(notification);
//     await _persistList(_scopedKey(_notificationsPrefix, uid), _notifications, (n) => n.toMap());
//   }

//   Future<void> replaceStockNotifications(List<NotificationModel> notifications) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     _notifications.removeWhere((notification) => notification.id.startsWith('stock-'));
//     _notifications.addAll(notifications);
//     await _persistList(_scopedKey(_notificationsPrefix, uid), _notifications, (n) => n.toMap());
//   }

//   Future<void> markNotificationAsRead(String id) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final index = _notifications.indexWhere((notification) => notification.id == id);
//     if (index != -1) {
//       _notifications[index] = _notifications[index].copyWith(isRead: true);
//       await _persistList(_scopedKey(_notificationsPrefix, uid), _notifications, (n) => n.toMap());
//     }
//   }

//   Future<void> markAllNotificationsAsRead() async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     for (var i = 0; i < _notifications.length; i++) {
//       _notifications[i] = _notifications[i].copyWith(isRead: true);
//     }
//     await _persistList(_scopedKey(_notificationsPrefix, uid), _notifications, (n) => n.toMap());
//   }

//   Future<int> deleteNotification(String id) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final before = _notifications.length;
//     _notifications.removeWhere((notification) => notification.id == id);
//     await _persistList(_scopedKey(_notificationsPrefix, uid), _notifications, (n) => n.toMap());
//     return before - _notifications.length;
//   }

//   Future<List<RoleModel>> getRoles() async {
//     await ensureInitialized();
//     return [..._roles];
//   }

//   Future<void> upsertRole(RoleModel role) async {
//     await ensureInitialized();
//     _roles.removeWhere((item) => item.id == role.id);
//     _roles.add(role);
//     await _persistList(_rolesKey, _roles, (r) => r.toMap());
//   }

//   Future<UserProfileModel> getProfile() async {
//     await ensureInitialized();
//     return _profile ?? const UserProfileModel(name: '', email: '', role: '', phone: '', department: '');
//   }

//   Future<void> upsertProfile(UserProfileModel profile) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     _profile = profile;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_scopedKey(_profilePrefix, uid), jsonEncode(profile.toMap()));
//   }

//   Future<SyncStatusModel> getSyncStatus() async {
//     await ensureInitialized();
//     return _syncStatus;
//   }

//   Future<void> upsertSyncStatus(SyncStatusModel status) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     _syncStatus = status;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_scopedKey(_syncStatusPrefix, uid), jsonEncode(status.toMap()));
//   }

//   Future<int> insertQueueItem(SyncQueueItem item) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final id = _syncQueue.length + 1;
//     _syncQueue.add(SyncQueueItem(
//       id: id,
//       collection: item.collection,
//       action: item.action,
//       recordId: item.recordId,
//       data: item.data,
//       createdAt: item.createdAt,
//     ));
//     await _persistList(_scopedKey(_syncQueuePrefix, uid), _syncQueue, (q) => q.toMap());
//     return id;
//   }

//   Future<List<SyncQueueItem>> getQueueItems() async {
//     if (_readUserId() == null) return [];
//     await ensureInitialized();
//     return [..._syncQueue];
//   }

//   Future<int> deleteQueueItem(int id) async {
//     final uid = _requireUserId();
//     await ensureInitialized();
//     final before = _syncQueue.length;
//     _syncQueue.removeWhere((item) => item.id == id);
//     await _persistList(_scopedKey(_syncQueuePrefix, uid), _syncQueue, (q) => q.toMap());
//     return before - _syncQueue.length;
//   }

//   Future<void> close() async {
//     _ready = false;
//     _loadedUserId = null;
//   }
// }
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

  // ── Storage keys (bumped to v4 for new fields) ──────────────────────────────
  static const _productsPrefix      = 'inventory_products_v4_';
  static const _categoriesPrefix    = 'inventory_categories_v4_';
  static const _suppliersPrefix     = 'inventory_suppliers_v4_';
  static const _salesPrefix         = 'inventory_sales_v4_';
  static const _purchasesPrefix     = 'inventory_purchases_v4_';
  static const _notificationsPrefix = 'inventory_notifications_v4_';
  static const _rolesPrefix          = 'inventory_roles_v5_';
  static const _profilePrefix       = 'inventory_profile_v4_';
  static const _syncStatusPrefix    = 'inventory_sync_status_v4_';
  static const _syncQueuePrefix     = 'inventory_sync_queue_v4_';

  // ── In-memory caches ────────────────────────────────────────────────────────
  final List<ProductModel>      _products      = [];
  final List<CategoryModel>     _categories    = [];
  final List<SupplierModel>     _suppliers     = [];
  final List<SalesModel>        _sales         = [];
  final List<PurchaseModel>     _purchases     = [];
  final List<NotificationModel> _notifications = [];
  final List<RoleModel>         _roles         = [];
  final List<SyncQueueItem>     _syncQueue     = [];
  UserProfileModel? _profile;
  SyncStatusModel _syncStatus = const SyncStatusModel();

  bool    _ready          = false;
  int     _nextProductId  = 1;
  String? _currentUserId;
  String? _loadedUserId;

  String? get currentUserId => _currentUserId;

  void setCurrentUserId(String? uid) {
    if (_currentUserId == uid) return;
    _currentUserId = uid;
    _ready = false;
  }

  String _requireUserId() {
    final uid = _currentUserId;
    if (uid == null || uid.isEmpty) {
      throw Exception(
        'No authenticated user. Sign in to access inventory data.',
      );
    }
    return uid;
  }

  String? _readUserId() {
    final uid = _currentUserId;
    if (uid == null || uid.isEmpty) return null;
    return uid;
  }

  String _scopedKey(String prefix, String uid) => '$prefix$uid';

  // ── Initialization ──────────────────────────────────────────────────────────

  Future<void> ensureInitialized() async {
    final uid = _readUserId();
    if (uid == null) return;
    if (_ready && _loadedUserId == uid) return;

    final prefs = await SharedPreferences.getInstance();

    _products
      ..clear()
      ..addAll(_readList(prefs, _scopedKey(_productsPrefix, uid), ProductModel.fromMap));
    _categories
      ..clear()
      ..addAll(_readList(prefs, _scopedKey(_categoriesPrefix, uid), CategoryModel.fromMap));
    _suppliers
      ..clear()
      ..addAll(_readList(prefs, _scopedKey(_suppliersPrefix, uid), SupplierModel.fromMap));
    _sales
      ..clear()
      ..addAll(_readList(prefs, _scopedKey(_salesPrefix, uid), SalesModel.fromMap));
    _purchases
      ..clear()
      ..addAll(_readList(prefs, _scopedKey(_purchasesPrefix, uid), PurchaseModel.fromMap));
    _notifications
      ..clear()
      ..addAll(_readList(prefs, _scopedKey(_notificationsPrefix, uid), NotificationModel.fromMap));
    _roles
      ..clear()
      ..addAll(_readList(prefs, _scopedKey(_rolesPrefix, uid), RoleModel.fromMap));

    final profileRaw = prefs.getString(_scopedKey(_profilePrefix, uid));
    _profile = profileRaw != null
        ? UserProfileModel.fromMap(_decodeMap(profileRaw))
        : null;

    final syncRaw = prefs.getString(_scopedKey(_syncStatusPrefix, uid));
    _syncStatus = syncRaw != null
        ? SyncStatusModel.fromMap(_decodeMap(syncRaw))
        : const SyncStatusModel();

    _syncQueue
      ..clear()
      ..addAll(_readList(prefs, _scopedKey(_syncQueuePrefix, uid), SyncQueueItem.fromMap));

    _nextProductId = _products.fold<int>(
      1,
      (maxId, p) =>
          p.id != null && p.id! >= maxId ? p.id! + 1 : maxId,
    );
    _loadedUserId = uid;
    _ready = true;
  }

  // ── SharedPreferences helpers ───────────────────────────────────────────────

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

  Map<String, dynamic> _decodeMap(String raw) =>
      Map<String, dynamic>.from(jsonDecode(raw) as Map);

  Future<void> _persistList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toMap,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items.map(toMap).toList()));
  }

  // ── Products ────────────────────────────────────────────────────────────────
  // ProductModel now carries imageUrl and barcode — no extra work here;
  // toMap()/fromMap() on the model handle serialisation automatically.

  Future<int> insertProduct(ProductModel product) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final id = product.id ?? _nextProductId++;
    _products.removeWhere((p) => p.id == id);
    _products.add(product.copyWith(id: id));
    await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
    return id;
  }

  Future<void> upsertProduct(ProductModel product) async {
    final uid = _requireUserId();
    await ensureInitialized();
    if (product.id == null) {
      await insertProduct(product);
      return;
    }
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      _products.add(product);
    } else {
      _products[index] = product;
    }
    await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
  }

  Future<List<ProductModel>> getProducts() async {
    if (_readUserId() == null) return [];
    await ensureInitialized();
    return ([..._products]..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<int> updateProduct(ProductModel product) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) return 0;
    _products[index] = product;
    await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
    return 1;
  }

  Future<int> deleteProduct(int id) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final before = _products.length;
    _products.removeWhere((p) => p.id == id);
    await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
    return before - _products.length;
  }

  // ── Categories ──────────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories() async {
    if (_readUserId() == null) return [];
    await ensureInitialized();
    return ([..._categories]..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<void> upsertCategory(CategoryModel category) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _categories.removeWhere((c) => c.id == category.id);
    _categories.add(category);
    await _persistList(_scopedKey(_categoriesPrefix, uid), _categories, (c) => c.toMap());
  }

  Future<int> deleteCategory(String id) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final before = _categories.length;
    _categories.removeWhere((c) => c.id == id);
    await _persistList(_scopedKey(_categoriesPrefix, uid), _categories, (c) => c.toMap());
    return before - _categories.length;
  }

  // ── Suppliers ───────────────────────────────────────────────────────────────

  Future<List<SupplierModel>> getSuppliers() async {
    if (_readUserId() == null) return [];
    await ensureInitialized();
    return ([..._suppliers]..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<void> upsertSupplier(SupplierModel supplier) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _suppliers.removeWhere((s) => s.id == supplier.id);
    _suppliers.add(supplier);
    await _persistList(_scopedKey(_suppliersPrefix, uid), _suppliers, (s) => s.toMap());
  }

  Future<int> deleteSupplier(String id) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final before = _suppliers.length;
    _suppliers.removeWhere((s) => s.id == id);
    await _persistList(_scopedKey(_suppliersPrefix, uid), _suppliers, (s) => s.toMap());
    return before - _suppliers.length;
  }

  // ── Sales ───────────────────────────────────────────────────────────────────
  // SalesModel now carries stockProductId and stockQuantity.
  // insertSale tracks which product was decremented so deleteSale can
  // restore the exact product — matching the IO implementation's behaviour.

  Future<List<SalesModel>> getSales() async {
    if (_readUserId() == null) return [];
    await ensureInitialized();
    return ([..._sales]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> insertSale(SalesModel sale) async {
    final uid = _requireUserId();
    await ensureInitialized();

    // Pick the product with the most stock and decrement it.
    final index = _products.indexWhere((p) => p.stock > 0);
    if (index == -1) {
      throw Exception('Sale blocked: no stock is available.');
    }

    final product = _products[index];
    _products[index] = product.copyWith(stock: product.stock - 1);

    _sales.add(sale);

    await _persistList(_scopedKey(_productsPrefix, uid), _products, (p) => p.toMap());
    await _persistList(_scopedKey(_salesPrefix, uid), _sales, (s) => s.toMap());
  }

  Future<void> upsertSale(SalesModel sale) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _sales.removeWhere((s) => s.id == sale.id);
    _sales.add(sale);
    await _persistList(_scopedKey(_salesPrefix, uid), _sales, (s) => s.toMap());
  }

  Future<int> deleteSale(String id) async {
    final uid = _requireUserId();
    await ensureInitialized();

    final saleIndex = _sales.indexWhere((s) => s.id == id);
    if (saleIndex == -1) return 0;

    _sales.removeAt(saleIndex);
    await _persistList(_scopedKey(_salesPrefix, uid), _sales, (s) => s.toMap());
    return 1;
  }

  // ── Purchases ───────────────────────────────────────────────────────────────

  Future<List<PurchaseModel>> getPurchases() async {
    if (_readUserId() == null) return [];
    await ensureInitialized();
    return ([..._purchases]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> insertPurchase(PurchaseModel purchase) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final index =
        _products.indexWhere((p) => p.supplier == purchase.supplierName);
    if (index != -1) {
      _products[index] =
          _products[index].copyWith(stock: _products[index].stock + 1);
      await _persistList(
        _scopedKey(_productsPrefix, uid),
        _products,
        (p) => p.toMap(),
      );
    }
    _purchases.add(purchase);
    await _persistList(
      _scopedKey(_purchasesPrefix, uid),
      _purchases,
      (p) => p.toMap(),
    );
  }

  Future<void> upsertPurchase(PurchaseModel purchase) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _purchases.removeWhere((p) => p.id == purchase.id);
    _purchases.add(purchase);
    await _persistList(
      _scopedKey(_purchasesPrefix, uid),
      _purchases,
      (p) => p.toMap(),
    );
  }

  Future<int> deletePurchase(String id) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final before = _purchases.length;
    _purchases.removeWhere((p) => p.id == id);
    await _persistList(
      _scopedKey(_purchasesPrefix, uid),
      _purchases,
      (p) => p.toMap(),
    );
    return before - _purchases.length;
  }

  // ── Notifications ───────────────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications() async {
    await ensureInitialized();
    return ([..._notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> upsertNotification(NotificationModel notification) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _notifications.removeWhere((n) => n.id == notification.id);
    _notifications.add(notification);
    await _persistList(
      _scopedKey(_notificationsPrefix, uid),
      _notifications,
      (n) => n.toMap(),
    );
  }

  Future<void> replaceStockNotifications(
    List<NotificationModel> notifications,
  ) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _notifications.removeWhere((n) => n.id.startsWith('stock-'));
    _notifications.addAll(notifications);
    await _persistList(
      _scopedKey(_notificationsPrefix, uid),
      _notifications,
      (n) => n.toMap(),
    );
  }

  Future<void> markNotificationAsRead(String id) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _persistList(
        _scopedKey(_notificationsPrefix, uid),
        _notifications,
        (n) => n.toMap(),
      );
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final uid = _requireUserId();
    await ensureInitialized();
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _persistList(
      _scopedKey(_notificationsPrefix, uid),
      _notifications,
      (n) => n.toMap(),
    );
  }

  Future<int> deleteNotification(String id) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final before = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);
    await _persistList(
      _scopedKey(_notificationsPrefix, uid),
      _notifications,
      (n) => n.toMap(),
    );
    return before - _notifications.length;
  }

  // ── Roles ───────────────────────────────────────────────────────────────────

  Future<List<RoleModel>> getRoles() async {
    await ensureInitialized();
    return [..._roles];
  }

  Future<void> upsertRole(RoleModel role) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _roles.removeWhere((r) => r.id == role.id);
    _roles.add(role);
    await _persistList(_scopedKey(_rolesPrefix, uid), _roles, (r) => r.toMap());
  }

  // ── User profile ────────────────────────────────────────────────────────────
  // UserProfileModel now carries photoUrl — serialisation is handled by the
  // model's toMap()/fromMap(); no extra changes needed here.

  Future<UserProfileModel> getProfile() async {
    await ensureInitialized();
    return _profile ??
        const UserProfileModel(
          name: '',
          email: '',
          role: '',
          phone: '',
          department: '',
          photoUrl: '',   // new field
        );
  }

  Future<void> upsertProfile(UserProfileModel profile) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scopedKey(_profilePrefix, uid),
      jsonEncode(profile.toMap()),
    );
  }

  // ── Sync status ─────────────────────────────────────────────────────────────

  Future<SyncStatusModel> getSyncStatus() async {
    await ensureInitialized();
    return _syncStatus;
  }

  Future<void> upsertSyncStatus(SyncStatusModel status) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _syncStatus = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scopedKey(_syncStatusPrefix, uid),
      jsonEncode(status.toMap()),
    );
  }

  // ── Sync queue ──────────────────────────────────────────────────────────────

  Future<int> insertQueueItem(SyncQueueItem item) async {
    final uid = _requireUserId();
    await ensureInitialized();
    _syncQueue.removeWhere(
      (q) => q.collection == item.collection && q.recordId == item.recordId,
    );
    final id = _syncQueue.length + 1;
    _syncQueue.add(SyncQueueItem(
      id: id,
      collection: item.collection,
      action: item.action,
      recordId: item.recordId,
      data: item.data,
      createdAt: item.createdAt,
    ));
    await _persistList(
      _scopedKey(_syncQueuePrefix, uid),
      _syncQueue,
      (q) => q.toMap(),
    );
    return id;
  }

  Future<List<SyncQueueItem>> getQueueItems() async {
    if (_readUserId() == null) return [];
    await ensureInitialized();
    return [..._syncQueue];
  }

  Future<int> deleteQueueItem(int id) async {
    final uid = _requireUserId();
    await ensureInitialized();
    final before = _syncQueue.length;
    _syncQueue.removeWhere((q) => q.id == id);
    await _persistList(
      _scopedKey(_syncQueuePrefix, uid),
      _syncQueue,
      (q) => q.toMap(),
    );
    return before - _syncQueue.length;
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  Future<void> close() async {
    _ready = false;
    _loadedUserId = null;
  }
}
