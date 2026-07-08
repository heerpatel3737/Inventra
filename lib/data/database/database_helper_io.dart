// import 'dart:io';

// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import '../../models/product_model.dart';
// import '../../models/category_model.dart';
// import '../../models/notification_model.dart';
// import '../../models/purchase_model.dart';
// import '../../models/role_model.dart';
// import '../../models/sales_model.dart';
// import '../../models/supplier_model.dart';
// import '../../models/sync_status_model.dart';
// import '../../models/user_profile_model.dart';
// import '../../models/sync_queue_item.dart';

// /// SQLite implementation for Android, iOS, Windows, macOS, and Linux.
// class DatabaseHelper {
//   DatabaseHelper._();

//   static final DatabaseHelper instance = DatabaseHelper._();

//   static const _databaseName = 'inventory.db';
//   static const _databaseVersion = 3;
//   static const _productsTable = 'products';
//   static const _categoriesTable = 'categories';
//   static const _suppliersTable = 'suppliers';
//   static const _salesTable = 'sales';
//   static const _purchasesTable = 'purchases';
//   static const _notificationsTable = 'notifications';
//   static const _rolesTable = 'roles';
//   static const _profileTable = 'user_profile';
//   static const _syncStatusTable = 'sync_status';

//   Database? _database;
//   bool _ffiInitialized = false;
//   String? _currentUserId;

//   String? get currentUserId => _currentUserId;

//   void setCurrentUserId(String? uid) {
//     _currentUserId = uid;
//   }

//   String _requireUserId() {
//     final uid = _currentUserId;
//     if (uid == null || uid.isEmpty) {
//       throw Exception('No authenticated user. Sign in to access inventory data.');
//     }
//     return uid;
//   }

//   String? _readUserId() {
//     final uid = _currentUserId;
//     if (uid == null || uid.isEmpty) return null;
//     return uid;
//   }

//   Future<void> ensureInitialized() async {
//     if (_database != null) return;

//     _initializeDesktopDatabaseFactory();

//     final documentsDirectory = await getApplicationDocumentsDirectory();
//     final path = p.join(documentsDirectory.path, _databaseName);

//     _database = await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: (db, version) => _createSchema(db),
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 3) {
//           await _migrateToV3(db);
//         }
//       },
//     );
//   }

//   void _initializeDesktopDatabaseFactory() {
//     if (_ffiInitialized) return;

//     if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
//       sqfliteFfiInit();
//       databaseFactory = databaseFactoryFfi;
//     }

//     _ffiInitialized = true;
//   }

//   Future<void> _createSchema(Database db) async {
//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_productsTable (
//   id INTEGER PRIMARY KEY AUTOINCREMENT,
//   name TEXT NOT NULL,
//   price REAL NOT NULL,
//   stock INTEGER NOT NULL CHECK(stock >= 0),
//   category TEXT NOT NULL,
//   supplier TEXT NOT NULL,
//   userId TEXT NOT NULL DEFAULT ''
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_categoriesTable (
//   id TEXT PRIMARY KEY,
//   name TEXT NOT NULL,
//   description TEXT NOT NULL DEFAULT '',
//   totalProducts INTEGER NOT NULL DEFAULT 0,
//   userId TEXT NOT NULL DEFAULT ''
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_suppliersTable (
//   id TEXT PRIMARY KEY,
//   name TEXT NOT NULL,
//   phone TEXT NOT NULL,
//   email TEXT NOT NULL,
//   address TEXT NOT NULL,
//   status TEXT NOT NULL,
//   userId TEXT NOT NULL DEFAULT ''
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_salesTable (
//   id TEXT PRIMARY KEY,
//   clientName TEXT NOT NULL,
//   amount REAL NOT NULL,
//   status TEXT NOT NULL,
//   createdAt TEXT NOT NULL,
//   stockProductId INTEGER,
//   stockQuantity INTEGER NOT NULL DEFAULT 1,
//   userId TEXT NOT NULL DEFAULT ''
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_purchasesTable (
//   id TEXT PRIMARY KEY,
//   supplierName TEXT NOT NULL,
//   amount REAL NOT NULL,
//   status TEXT NOT NULL,
//   createdAt TEXT NOT NULL,
//   expectedDelivery TEXT NOT NULL,
//   stockProductId INTEGER,
//   stockQuantity INTEGER NOT NULL DEFAULT 1,
//   userId TEXT NOT NULL DEFAULT ''
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_notificationsTable (
//   id TEXT PRIMARY KEY,
//   category TEXT NOT NULL,
//   title TEXT NOT NULL,
//   message TEXT NOT NULL,
//   createdAt TEXT NOT NULL,
//   isRead INTEGER NOT NULL DEFAULT 0
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_rolesTable (
//   id TEXT PRIMARY KEY,
//   name TEXT NOT NULL,
//   description TEXT NOT NULL,
//   permissions TEXT NOT NULL
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_profileTable (
//   id INTEGER PRIMARY KEY CHECK(id = 1),
//   name TEXT NOT NULL,
//   email TEXT NOT NULL,
//   role TEXT NOT NULL,
//   phone TEXT NOT NULL,
//   department TEXT NOT NULL
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS $_syncStatusTable (
//   id INTEGER PRIMARY KEY CHECK(id = 1),
//   lastSuccessfulSync TEXT,
//   pendingRecords INTEGER NOT NULL DEFAULT 0,
//   conflictCount INTEGER NOT NULL DEFAULT 0
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS sync_queue (
//   id INTEGER PRIMARY KEY AUTOINCREMENT,
//   collection TEXT NOT NULL,
//   action TEXT NOT NULL,
//   recordId TEXT NOT NULL,
//   data TEXT NOT NULL,
//   createdAt TEXT NOT NULL,
//   userId TEXT NOT NULL DEFAULT ''
// )
// ''');
//   }

//   Future<void> _migrateToV3(Database db) async {
//     for (final table in [
//       _productsTable,
//       _categoriesTable,
//       _suppliersTable,
//       _salesTable,
//       _purchasesTable,
//       'sync_queue',
//     ]) {
//       await db.execute(
//         'ALTER TABLE $table ADD COLUMN userId TEXT NOT NULL DEFAULT ""',
//       );
//     }
//   }

//   Future<int> insertProduct(ProductModel product) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     return _database!.insert(
//       _productsTable,
//       product.toMap()
//         ..remove('id')
//         ..['userId'] = userId,
//       conflictAlgorithm: ConflictAlgorithm.abort,
//     );
//   }

//   Future<List<ProductModel>> getProducts() async {
//     final userId = _readUserId();
//     if (userId == null) return [];
//     await ensureInitialized();
//     final rows = await _database!.query(
//       _productsTable,
//       where: 'userId = ?',
//       whereArgs: [userId],
//       orderBy: 'name ASC',
//     );
//     return rows.map(ProductModel.fromMap).toList();
//   }

//   Future<int> updateProduct(ProductModel product) async {
//     if (product.id == null) {
//       throw Exception('Cannot update a product without an id.');
//     }

//     final userId = _requireUserId();
//     await ensureInitialized();
//     return _database!.update(
//       _productsTable,
//       product.toMap()..remove('id'),
//       where: 'id = ? AND userId = ?',
//       whereArgs: [product.id, userId],
//     );
//   }

//   Future<int> deleteProduct(int id) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     return _database!.delete(
//       _productsTable,
//       where: 'id = ? AND userId = ?',
//       whereArgs: [id, userId],
//     );
//   }

//   Future<List<CategoryModel>> getCategories() async {
//     final userId = _readUserId();
//     if (userId == null) return [];
//     await ensureInitialized();
//     final rows = await _database!.query(
//       _categoriesTable,
//       where: 'userId = ?',
//       whereArgs: [userId],
//       orderBy: 'name ASC',
//     );
//     return rows.map(CategoryModel.fromMap).toList();
//   }

//   Future<void> upsertCategory(CategoryModel category) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     await _database!.insert(
//       _categoriesTable,
//       category.toMap()..['userId'] = userId,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<int> deleteCategory(String id) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     return _database!.delete(
//       _categoriesTable,
//       where: 'id = ? AND userId = ?',
//       whereArgs: [id, userId],
//     );
//   }

//   Future<List<SupplierModel>> getSuppliers() async {
//     final userId = _readUserId();
//     if (userId == null) return [];
//     await ensureInitialized();
//     final rows = await _database!.query(
//       _suppliersTable,
//       where: 'userId = ?',
//       whereArgs: [userId],
//       orderBy: 'name ASC',
//     );
//     return rows.map(SupplierModel.fromMap).toList();
//   }

//   Future<void> upsertSupplier(SupplierModel supplier) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     await _database!.insert(
//       _suppliersTable,
//       supplier.toMap()..['userId'] = userId,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<int> deleteSupplier(String id) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     return _database!.delete(
//       _suppliersTable,
//       where: 'id = ? AND userId = ?',
//       whereArgs: [id, userId],
//     );
//   }

//   Future<List<SalesModel>> getSales() async {
//     final userId = _readUserId();
//     if (userId == null) return [];
//     await ensureInitialized();
//     final rows = await _database!.query(
//       _salesTable,
//       where: 'userId = ?',
//       whereArgs: [userId],
//       orderBy: 'createdAt DESC',
//     );
//     return rows.map(SalesModel.fromMap).toList();
//   }

//   Future<void> insertSale(SalesModel sale) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     await _database!.transaction((txn) async {
//       final product = await _findSaleStockProduct(txn, userId);
//       if (product == null) {
//         throw Exception('Sale blocked: no stock is available.');
//       }

//       final productId = product['id'] as int;
//       final currentStock = product['stock'] as int;
//       if (currentStock <= 0) {
//         throw Exception('Sale blocked: stock cannot go negative.');
//       }

//       await txn.update(
//         _productsTable,
//         {'stock': currentStock - 1},
//         where: 'id = ? AND userId = ?',
//         whereArgs: [productId, userId],
//       );
//       await txn.insert(
//         _salesTable,
//         {
//           ...sale.toMap(),
//           'stockProductId': productId,
//           'stockQuantity': 1,
//           'userId': userId,
//         },
//         conflictAlgorithm: ConflictAlgorithm.abort,
//       );
//     });
//   }

//   Future<void> upsertSale(SalesModel sale) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     await _database!.insert(
//       _salesTable,
//       sale.toMap()..['userId'] = userId,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<int> deleteSale(String id) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     return _database!.transaction((txn) async {
//       final rows = await txn.query(
//         _salesTable,
//         where: 'id = ? AND userId = ?',
//         whereArgs: [id, userId],
//         limit: 1,
//       );
//       if (rows.isEmpty) return 0;

//       await _restoreStock(txn, rows.first, userId);
//       return txn.delete(
//         _salesTable,
//         where: 'id = ? AND userId = ?',
//         whereArgs: [id, userId],
//       );
//     });
//   }

//   Future<List<PurchaseModel>> getPurchases() async {
//     final userId = _readUserId();
//     if (userId == null) return [];
//     await ensureInitialized();
//     final rows = await _database!.query(
//       _purchasesTable,
//       where: 'userId = ?',
//       whereArgs: [userId],
//       orderBy: 'createdAt DESC',
//     );
//     return rows.map(PurchaseModel.fromMap).toList();
//   }

//   Future<void> insertPurchase(PurchaseModel purchase) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     await _database!.transaction((txn) async {
//       final product = await _findPurchaseStockProduct(txn, purchase.supplierName, userId);
//       final productId = product?['id'] as int?;

//       if (productId != null) {
//         await txn.update(
//           _productsTable,
//           {'stock': (product!['stock'] as int) + 1},
//           where: 'id = ? AND userId = ?',
//           whereArgs: [productId, userId],
//         );
//       }

//       await txn.insert(
//         _purchasesTable,
//         {
//           ...purchase.toMap(),
//           'stockProductId': productId,
//           'stockQuantity': productId == null ? 0 : 1,
//           'userId': userId,
//         },
//         conflictAlgorithm: ConflictAlgorithm.abort,
//       );
//     });
//   }

//   Future<void> upsertPurchase(PurchaseModel purchase) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     await _database!.insert(
//       _purchasesTable,
//       purchase.toMap()..['userId'] = userId,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<int> deletePurchase(String id) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     return _database!.transaction((txn) async {
//       final rows = await txn.query(
//         _purchasesTable,
//         where: 'id = ? AND userId = ?',
//         whereArgs: [id, userId],
//         limit: 1,
//       );
//       if (rows.isEmpty) return 0;

//       final productId = rows.first['stockProductId'] as int?;
//       final quantity = rows.first['stockQuantity'] as int? ?? 0;
//       if (productId != null && quantity > 0) {
//         final products = await txn.query(
//           _productsTable,
//           columns: ['stock'],
//           where: 'id = ? AND userId = ?',
//           whereArgs: [productId, userId],
//           limit: 1,
//         );
//         if (products.isNotEmpty) {
//           final currentStock = products.first['stock'] as int;
//           if (currentStock - quantity < 0) {
//             throw Exception('Purchase delete blocked: stock cannot go negative.');
//           }
//           await txn.update(
//             _productsTable,
//             {'stock': currentStock - quantity},
//             where: 'id = ? AND userId = ?',
//             whereArgs: [productId, userId],
//           );
//         }
//       }

//       return txn.delete(
//         _purchasesTable,
//         where: 'id = ? AND userId = ?',
//         whereArgs: [id, userId],
//       );
//     });
//   }

//   Future<List<NotificationModel>> getNotifications() async {
//     await ensureInitialized();
//     final rows = await _database!.query(_notificationsTable, orderBy: 'createdAt DESC');
//     return rows.map(NotificationModel.fromMap).toList();
//   }

//   Future<void> upsertNotification(NotificationModel notification) async {
//     await ensureInitialized();
//     await _database!.insert(
//       _notificationsTable,
//       notification.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<void> replaceStockNotifications(List<NotificationModel> notifications) async {
//     await ensureInitialized();
//     await _database!.transaction((txn) async {
//       await txn.delete(_notificationsTable, where: 'id LIKE ?', whereArgs: ['stock-%']);
//       for (final notification in notifications) {
//         await txn.insert(
//           _notificationsTable,
//           notification.toMap(),
//           conflictAlgorithm: ConflictAlgorithm.replace,
//         );
//       }
//     });
//   }

//   Future<void> markNotificationAsRead(String id) async {
//     await ensureInitialized();
//     await _database!.update(_notificationsTable, {'isRead': 1}, where: 'id = ?', whereArgs: [id]);
//   }

//   Future<void> markAllNotificationsAsRead() async {
//     await ensureInitialized();
//     await _database!.update(_notificationsTable, {'isRead': 1});
//   }

//   Future<int> deleteNotification(String id) async {
//     await ensureInitialized();
//     return _database!.delete(_notificationsTable, where: 'id = ?', whereArgs: [id]);
//   }

//   Future<List<RoleModel>> getRoles() async {
//     await ensureInitialized();
//     final rows = await _database!.query(_rolesTable, orderBy: 'name ASC');
//     return rows.map(RoleModel.fromMap).toList();
//   }

//   Future<void> upsertRole(RoleModel role) async {
//     await ensureInitialized();
//     await _database!.insert(_rolesTable, role.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   Future<UserProfileModel> getProfile() async {
//     await ensureInitialized();
//     final rows = await _database!.query(_profileTable, where: 'id = 1', limit: 1);
//     if (rows.isEmpty) {
//       const profile = UserProfileModel(
//         name: '',
//         email: '',
//         role: '',
//         phone: '',
//         department: '',
//       );
//       await upsertProfile(profile);
//       return profile;
//     }
//     return UserProfileModel.fromMap(rows.first);
//   }

//   Future<void> upsertProfile(UserProfileModel profile) async {
//     await ensureInitialized();
//     await _database!.insert(
//       _profileTable,
//       profile.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<SyncStatusModel> getSyncStatus() async {
//     await ensureInitialized();
//     final rows = await _database!.query(_syncStatusTable, where: 'id = 1', limit: 1);
//     if (rows.isEmpty) {
//       const status = SyncStatusModel();
//       await upsertSyncStatus(status);
//       return status;
//     }
//     return SyncStatusModel.fromMap(rows.first);
//   }

//   Future<void> upsertSyncStatus(SyncStatusModel status) async {
//     await ensureInitialized();
//     await _database!.insert(
//       _syncStatusTable,
//       status.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<Map<String, Object?>?> _findSaleStockProduct(Transaction txn, String userId) async {
//     final rows = await txn.query(
//       _productsTable,
//       where: 'stock > 0 AND userId = ?',
//       whereArgs: [userId],
//       orderBy: 'stock DESC, name ASC',
//       limit: 1,
//     );
//     return rows.isEmpty ? null : rows.first;
//   }

//   Future<Map<String, Object?>?> _findPurchaseStockProduct(
//     Transaction txn,
//     String supplierName,
//     String userId,
//   ) async {
//     final supplierRows = await txn.query(
//       _productsTable,
//       where: 'supplier = ? AND userId = ?',
//       whereArgs: [supplierName, userId],
//       orderBy: 'name ASC',
//       limit: 1,
//     );
//     if (supplierRows.isNotEmpty) return supplierRows.first;

//     final rows = await txn.query(
//       _productsTable,
//       where: 'userId = ?',
//       whereArgs: [userId],
//       orderBy: 'name ASC',
//       limit: 1,
//     );
//     return rows.isEmpty ? null : rows.first;
//   }

//   Future<void> _restoreStock(
//     Transaction txn,
//     Map<String, Object?> transactionRow,
//     String userId,
//   ) async {
//     final productId = transactionRow['stockProductId'] as int?;
//     final quantity = transactionRow['stockQuantity'] as int? ?? 0;
//     if (productId == null || quantity <= 0) return;

//     final products = await txn.query(
//       _productsTable,
//       columns: ['stock'],
//       where: 'id = ? AND userId = ?',
//       whereArgs: [productId, userId],
//       limit: 1,
//     );
//     if (products.isEmpty) return;

//     await txn.update(
//       _productsTable,
//       {'stock': (products.first['stock'] as int) + quantity},
//       where: 'id = ? AND userId = ?',
//       whereArgs: [productId, userId],
//     );
//   }

//   Future<int> insertQueueItem(SyncQueueItem item) async {
//     final userId = _requireUserId();
//     await ensureInitialized();
//     return _database!.insert(
//       'sync_queue',
//       item.toMap()
//         ..remove('id')
//         ..['userId'] = userId,
//     );
//   }

//   Future<List<SyncQueueItem>> getQueueItems() async {
//     final userId = _readUserId();
//     if (userId == null) return [];
//     await ensureInitialized();
//     final rows = await _database!.query(
//       'sync_queue',
//       where: 'userId = ?',
//       whereArgs: [userId],
//       orderBy: 'createdAt ASC',
//     );
//     return rows.map(SyncQueueItem.fromMap).toList();
//   }

//   Future<int> deleteQueueItem(int id) async {
//     await ensureInitialized();
//     return _database!.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<void> close() async {
//     final db = _database;
//     if (db != null) {
//       await db.close();
//       _database = null;
//     }
//   }
// }
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/notification_model.dart';
import '../../models/purchase_model.dart';
import '../../models/role_model.dart';
import '../../models/sales_model.dart';
import '../../models/supplier_model.dart';
import '../../models/sync_status_model.dart';
import '../../models/user_profile_model.dart';
import '../../models/sync_queue_item.dart';

/// SQLite implementation for Android, iOS, Windows, macOS, and Linux.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'inventory.db';

  // ── Bump to 5 for per-user isolation on all tables ─────────────────────────
  static const _databaseVersion = 5;

  static const _productsTable      = 'products';
  static const _categoriesTable    = 'categories';
  static const _suppliersTable     = 'suppliers';
  static const _salesTable         = 'sales';
  static const _purchasesTable     = 'purchases';
  static const _notificationsTable = 'notifications';
  static const _rolesTable         = 'roles';
  static const _profileTable       = 'user_profile';
  static const _syncStatusTable    = 'sync_status';

  Database? _database;
  bool _ffiInitialized = false;
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  void setCurrentUserId(String? uid) {
    _currentUserId = uid;
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

  // ── Initialization ──────────────────────────────────────────────────────────

  Future<void> ensureInitialized() async {
    if (_database != null) return;

    _initializeDesktopDatabaseFactory();

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) await _migrateToV3(db);
        if (oldVersion < 4) await _migrateToV4(db);
        if (oldVersion < 5) await _migrateToV5(db);
      },
    );
  }

  void _initializeDesktopDatabaseFactory() {
    if (_ffiInitialized) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiInitialized = true;
  }

  // ── Schema creation (fresh install) ────────────────────────────────────────

  Future<void> _createSchema(Database db) async {
    // products — per-user composite primary key
    await db.execute('''
CREATE TABLE IF NOT EXISTS $_productsTable (
  id          INTEGER NOT NULL,
  name        TEXT    NOT NULL,
  price       REAL    NOT NULL,
  stock       INTEGER NOT NULL CHECK(stock >= 0),
  category    TEXT    NOT NULL,
  supplier    TEXT    NOT NULL,
  imageUrl    TEXT    NOT NULL DEFAULT '',
  barcode     TEXT    NOT NULL DEFAULT '',
  userId      TEXT    NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_categoriesTable (
  id            TEXT    NOT NULL,
  name          TEXT    NOT NULL,
  description   TEXT    NOT NULL DEFAULT '',
  totalProducts INTEGER NOT NULL DEFAULT 0,
  userId        TEXT    NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_suppliersTable (
  id      TEXT NOT NULL,
  name    TEXT NOT NULL,
  phone   TEXT NOT NULL,
  email   TEXT NOT NULL,
  address TEXT NOT NULL,
  status  TEXT NOT NULL,
  userId  TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_salesTable (
  id             TEXT    NOT NULL,
  clientName     TEXT    NOT NULL,
  amount         REAL    NOT NULL,
  status         TEXT    NOT NULL,
  createdAt      TEXT    NOT NULL,
  stockProductId INTEGER,
  stockQuantity  INTEGER NOT NULL DEFAULT 1,
  userId         TEXT    NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_purchasesTable (
  id               TEXT    NOT NULL,
  supplierName     TEXT    NOT NULL,
  amount           REAL    NOT NULL,
  status           TEXT    NOT NULL,
  createdAt        TEXT    NOT NULL,
  expectedDelivery TEXT    NOT NULL,
  stockProductId   INTEGER,
  stockQuantity    INTEGER NOT NULL DEFAULT 1,
  userId           TEXT    NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_notificationsTable (
  id        TEXT    NOT NULL,
  category  TEXT    NOT NULL,
  title     TEXT    NOT NULL,
  message   TEXT    NOT NULL,
  createdAt TEXT    NOT NULL,
  isRead    INTEGER NOT NULL DEFAULT 0,
  userId    TEXT    NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_rolesTable (
  id          TEXT NOT NULL,
  name        TEXT NOT NULL,
  description TEXT NOT NULL,
  permissions TEXT NOT NULL,
  userId      TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_profileTable (
  userId     TEXT PRIMARY KEY,
  name       TEXT    NOT NULL,
  email      TEXT    NOT NULL,
  role       TEXT    NOT NULL,
  phone      TEXT    NOT NULL,
  department TEXT    NOT NULL,
  photoUrl   TEXT    NOT NULL DEFAULT ''
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_syncStatusTable (
  userId             TEXT PRIMARY KEY,
  lastSuccessfulSync TEXT,
  pendingRecords     INTEGER NOT NULL DEFAULT 0,
  conflictCount      INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS sync_queue (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  collection TEXT    NOT NULL,
  action     TEXT    NOT NULL,
  recordId   TEXT    NOT NULL,
  data       TEXT    NOT NULL,
  createdAt  TEXT    NOT NULL,
  userId     TEXT    NOT NULL DEFAULT ''
)
''');
  }

  // ── Migrations ──────────────────────────────────────────────────────────────

  /// V2 → V3: add userId column to all user-scoped tables.
  Future<void> _migrateToV3(Database db) async {
    for (final table in [
      _productsTable,
      _categoriesTable,
      _suppliersTable,
      _salesTable,
      _purchasesTable,
      'sync_queue',
    ]) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN userId TEXT NOT NULL DEFAULT ""',
      );
    }
  }

  /// V3 → V4: add imageUrl + barcode to products,
  ///           photoUrl to user_profile,
  ///           stockProductId + stockQuantity to sales.
  Future<void> _migrateToV4(Database db) async {
    // products
    await db.execute(
      'ALTER TABLE $_productsTable ADD COLUMN imageUrl TEXT NOT NULL DEFAULT ""',
    );
    await db.execute(
      'ALTER TABLE $_productsTable ADD COLUMN barcode TEXT NOT NULL DEFAULT ""',
    );

    // user_profile
    await db.execute(
      'ALTER TABLE $_profileTable ADD COLUMN photoUrl TEXT NOT NULL DEFAULT ""',
    );

    // sales — stockProductId and stockQuantity may already exist on installs
    // that ran _createSchema at v3, so guard each with a try/catch.
    for (final sql in [
      'ALTER TABLE $_salesTable ADD COLUMN stockProductId INTEGER',
      'ALTER TABLE $_salesTable ADD COLUMN stockQuantity INTEGER NOT NULL DEFAULT 1',
    ]) {
      try {
        await db.execute(sql);
      } catch (_) {
        // Column already exists — safe to ignore.
      }
    }
  }

  /// V4 → V5: per-user composite keys and userId on all remaining tables.
  Future<void> _migrateToV5(Database db) async {
    await _recreateTableWithCompositePk(
      db,
      _productsTable,
      '''
  id INTEGER NOT NULL,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  stock INTEGER NOT NULL CHECK(stock >= 0),
  category TEXT NOT NULL,
  supplier TEXT NOT NULL,
  imageUrl TEXT NOT NULL DEFAULT '',
  barcode TEXT NOT NULL DEFAULT '',
  userId TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
''',
      'id, name, price, stock, category, supplier, imageUrl, barcode, userId',
    );

    await _recreateTableWithCompositePk(
      db,
      _categoriesTable,
      '''
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  totalProducts INTEGER NOT NULL DEFAULT 0,
  userId TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
''',
      'id, name, description, totalProducts, userId',
    );

    await _recreateTableWithCompositePk(
      db,
      _suppliersTable,
      '''
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  address TEXT NOT NULL,
  status TEXT NOT NULL,
  userId TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
''',
      'id, name, phone, email, address, status, userId',
    );

    await _recreateTableWithCompositePk(
      db,
      _salesTable,
      '''
  id TEXT NOT NULL,
  clientName TEXT NOT NULL,
  amount REAL NOT NULL,
  status TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  stockProductId INTEGER,
  stockQuantity INTEGER NOT NULL DEFAULT 1,
  userId TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
''',
      'id, clientName, amount, status, createdAt, stockProductId, stockQuantity, userId',
    );

    await _recreateTableWithCompositePk(
      db,
      _purchasesTable,
      '''
  id TEXT NOT NULL,
  supplierName TEXT NOT NULL,
  amount REAL NOT NULL,
  status TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  expectedDelivery TEXT NOT NULL,
  stockProductId INTEGER,
  stockQuantity INTEGER NOT NULL DEFAULT 1,
  userId TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
''',
      'id, supplierName, amount, status, createdAt, expectedDelivery, stockProductId, stockQuantity, userId',
    );

    try {
      await db.execute(
        'ALTER TABLE $_notificationsTable ADD COLUMN userId TEXT NOT NULL DEFAULT ""',
      );
    } catch (_) {}

    await _recreateTableWithCompositePk(
      db,
      _notificationsTable,
      '''
  id TEXT NOT NULL,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  isRead INTEGER NOT NULL DEFAULT 0,
  userId TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
''',
      'id, category, title, message, createdAt, isRead, userId',
    );

    try {
      await db.execute(
        'ALTER TABLE $_rolesTable ADD COLUMN userId TEXT NOT NULL DEFAULT ""',
      );
    } catch (_) {}

    await _recreateTableWithCompositePk(
      db,
      _rolesTable,
      '''
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  permissions TEXT NOT NULL,
  userId TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (id, userId)
''',
      'id, name, description, permissions, userId',
    );

    await db.execute('''
CREATE TABLE IF NOT EXISTS ${_profileTable}_v5 (
  userId TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL,
  phone TEXT NOT NULL,
  department TEXT NOT NULL,
  photoUrl TEXT NOT NULL DEFAULT ''
)
''');
    await db.execute('DROP TABLE IF EXISTS $_profileTable');
    await db.execute(
      'ALTER TABLE ${_profileTable}_v5 RENAME TO $_profileTable',
    );

    await db.execute('''
CREATE TABLE IF NOT EXISTS ${_syncStatusTable}_v5 (
  userId TEXT PRIMARY KEY,
  lastSuccessfulSync TEXT,
  pendingRecords INTEGER NOT NULL DEFAULT 0,
  conflictCount INTEGER NOT NULL DEFAULT 0
)
''');
    await db.execute('DROP TABLE IF EXISTS $_syncStatusTable');
    await db.execute(
      'ALTER TABLE ${_syncStatusTable}_v5 RENAME TO $_syncStatusTable',
    );
  }

  Future<void> _recreateTableWithCompositePk(
    Database db,
    String table,
    String columnDefs,
    String selectColumns,
  ) async {
    final tempTable = '${table}_v5';
    await db.execute('CREATE TABLE $tempTable ($columnDefs)');
    await db.execute(
      'INSERT INTO $tempTable ($selectColumns) SELECT $selectColumns FROM $table',
    );
    await db.execute('DROP TABLE $table');
    await db.execute('ALTER TABLE $tempTable RENAME TO $table');
  }

  // ── Products ────────────────────────────────────────────────────────────────

  Future<int> insertProduct(ProductModel product) async {
    final userId = _requireUserId();
    await ensureInitialized();

    final id = product.id ?? await _nextProductId(userId);
    await _database!.insert(
      _productsTable,
      product.toMap()
        ..['id'] = id
        ..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> upsertProduct(ProductModel product) async {
    if (product.id == null) {
      await insertProduct(product);
      return;
    }
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _productsTable,
      product.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> _nextProductId(String userId) async {
    final result = await _database!.rawQuery(
      'SELECT COALESCE(MAX(id), 0) + 1 AS nextId FROM $_productsTable WHERE userId = ?',
      [userId],
    );
    return result.first['nextId'] as int;
  }

  Future<List<ProductModel>> getProducts() async {
    final userId = _readUserId();
    if (userId == null) return [];
    await ensureInitialized();
    final rows = await _database!.query(
      _productsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    if (product.id == null) {
      throw Exception('Cannot update a product without an id.');
    }
    final userId = _requireUserId();
    await ensureInitialized();
    return _database!.update(
      _productsTable,
      product.toMap()..remove('id'),
      where: 'id = ? AND userId = ?',
      whereArgs: [product.id, userId],
    );
  }

  Future<int> deleteProduct(int id) async {
    final userId = _requireUserId();
    await ensureInitialized();
    return _database!.delete(
      _productsTable,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // ── Categories ──────────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories() async {
    final userId = _readUserId();
    if (userId == null) return [];
    await ensureInitialized();
    final rows = await _database!.query(
      _categoriesTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<void> upsertCategory(CategoryModel category) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _categoriesTable,
      category.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteCategory(String id) async {
    final userId = _requireUserId();
    await ensureInitialized();
    return _database!.delete(
      _categoriesTable,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // ── Suppliers ───────────────────────────────────────────────────────────────

  Future<List<SupplierModel>> getSuppliers() async {
    final userId = _readUserId();
    if (userId == null) return [];
    await ensureInitialized();
    final rows = await _database!.query(
      _suppliersTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return rows.map(SupplierModel.fromMap).toList();
  }

  Future<void> upsertSupplier(SupplierModel supplier) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _suppliersTable,
      supplier.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteSupplier(String id) async {
    final userId = _requireUserId();
    await ensureInitialized();
    return _database!.delete(
      _suppliersTable,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // ── Sales ───────────────────────────────────────────────────────────────────

  Future<List<SalesModel>> getSales() async {
    final userId = _readUserId();
    if (userId == null) return [];
    await ensureInitialized();
    final rows = await _database!.query(
      _salesTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(SalesModel.fromMap).toList();
  }

  Future<void> insertSale(SalesModel sale) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.transaction((txn) async {
      final product = await _findSaleStockProduct(txn, userId);
      if (product == null) {
        throw Exception('Sale blocked: no stock is available.');
      }
      final productId    = product['id'] as int;
      final currentStock = product['stock'] as int;
      if (currentStock <= 0) {
        throw Exception('Sale blocked: stock cannot go negative.');
      }
      await txn.update(
        _productsTable,
        {'stock': currentStock - 1},
        where: 'id = ? AND userId = ?',
        whereArgs: [productId, userId],
      );
      await txn.insert(
        _salesTable,
        {
          ...sale.toMap(),
          'stockProductId': productId,
          'stockQuantity': 1,
          'userId': userId,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<void> upsertSale(SalesModel sale) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _salesTable,
      sale.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteSale(String id) async {
    final userId = _requireUserId();
    await ensureInitialized();
    return _database!.transaction((txn) async {
      final rows = await txn.query(
        _salesTable,
        where: 'id = ? AND userId = ?',
        whereArgs: [id, userId],
        limit: 1,
      );
      if (rows.isEmpty) return 0;
      await _restoreStock(txn, rows.first, userId);
      return txn.delete(
        _salesTable,
        where: 'id = ? AND userId = ?',
        whereArgs: [id, userId],
      );
    });
  }

  // ── Purchases ───────────────────────────────────────────────────────────────

  Future<List<PurchaseModel>> getPurchases() async {
    final userId = _readUserId();
    if (userId == null) return [];
    await ensureInitialized();
    final rows = await _database!.query(
      _purchasesTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(PurchaseModel.fromMap).toList();
  }

  Future<void> insertPurchase(PurchaseModel purchase) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.transaction((txn) async {
      final product   = await _findPurchaseStockProduct(txn, purchase.supplierName, userId);
      final productId = product?['id'] as int?;
      if (productId != null) {
        await txn.update(
          _productsTable,
          {'stock': (product!['stock'] as int) + 1},
          where: 'id = ? AND userId = ?',
          whereArgs: [productId, userId],
        );
      }
      await txn.insert(
        _purchasesTable,
        {
          ...purchase.toMap(),
          'stockProductId': productId,
          'stockQuantity': productId == null ? 0 : 1,
          'userId': userId,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<void> upsertPurchase(PurchaseModel purchase) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _purchasesTable,
      purchase.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deletePurchase(String id) async {
    final userId = _requireUserId();
    await ensureInitialized();
    return _database!.transaction((txn) async {
      final rows = await txn.query(
        _purchasesTable,
        where: 'id = ? AND userId = ?',
        whereArgs: [id, userId],
        limit: 1,
      );
      if (rows.isEmpty) return 0;

      final productId = rows.first['stockProductId'] as int?;
      final quantity  = rows.first['stockQuantity'] as int? ?? 0;
      if (productId != null && quantity > 0) {
        final products = await txn.query(
          _productsTable,
          columns: ['stock'],
          where: 'id = ? AND userId = ?',
          whereArgs: [productId, userId],
          limit: 1,
        );
        if (products.isNotEmpty) {
          final currentStock = products.first['stock'] as int;
          if (currentStock - quantity < 0) {
            throw Exception(
              'Purchase delete blocked: stock cannot go negative.',
            );
          }
          await txn.update(
            _productsTable,
            {'stock': currentStock - quantity},
            where: 'id = ? AND userId = ?',
            whereArgs: [productId, userId],
          );
        }
      }

      return txn.delete(
        _purchasesTable,
        where: 'id = ? AND userId = ?',
        whereArgs: [id, userId],
      );
    });
  }

  // ── Notifications ───────────────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications() async {
    final userId = _readUserId();
    if (userId == null) return [];
    await ensureInitialized();
    final rows = await _database!.query(
      _notificationsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(NotificationModel.fromMap).toList();
  }

  Future<void> upsertNotification(NotificationModel notification) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _notificationsTable,
      notification.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> replaceStockNotifications(
    List<NotificationModel> notifications,
  ) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.transaction((txn) async {
      await txn.delete(
        _notificationsTable,
        where: 'id LIKE ? AND userId = ?',
        whereArgs: ['stock-%', userId],
      );
      for (final n in notifications) {
        await txn.insert(
          _notificationsTable,
          n.toMap()..['userId'] = userId,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> markNotificationAsRead(String id) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.update(
      _notificationsTable,
      {'isRead': 1},
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.update(
      _notificationsTable,
      {'isRead': 1},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteNotification(String id) async {
    final userId = _requireUserId();
    await ensureInitialized();
    return _database!.delete(
      _notificationsTable,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // ── Roles ───────────────────────────────────────────────────────────────────

  Future<List<RoleModel>> getRoles() async {
    final userId = _readUserId();
    if (userId == null) return [];
    await ensureInitialized();
    final rows = await _database!.query(
      _rolesTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return rows.map(RoleModel.fromMap).toList();
  }

  Future<void> upsertRole(RoleModel role) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _rolesTable,
      role.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── User profile ────────────────────────────────────────────────────────────

  Future<UserProfileModel> getProfile() async {
    final userId = _requireUserId();
    await ensureInitialized();
    final rows = await _database!.query(
      _profileTable,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      const profile = UserProfileModel(
        name: '',
        email: '',
        role: '',
        phone: '',
        department: '',
        photoUrl: '',
      );
      await upsertProfile(profile);
      return profile;
    }
    return UserProfileModel.fromMap(rows.first);
  }

  Future<void> upsertProfile(UserProfileModel profile) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _profileTable,
      profile.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Sync status ─────────────────────────────────────────────────────────────

  Future<SyncStatusModel> getSyncStatus() async {
    final userId = _requireUserId();
    await ensureInitialized();
    final rows = await _database!.query(
      _syncStatusTable,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      const status = SyncStatusModel();
      await upsertSyncStatus(status);
      return status;
    }
    return SyncStatusModel.fromMap(rows.first);
  }

  Future<void> upsertSyncStatus(SyncStatusModel status) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.insert(
      _syncStatusTable,
      status.toMap()..['userId'] = userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Sync queue ──────────────────────────────────────────────────────────────

  Future<int> insertQueueItem(SyncQueueItem item) async {
    final userId = _requireUserId();
    await ensureInitialized();
    await _database!.delete(
      'sync_queue',
      where: 'collection = ? AND recordId = ? AND userId = ?',
      whereArgs: [item.collection, item.recordId, userId],
    );
    return _database!.insert(
      'sync_queue',
      item.toMap()
        ..remove('id')
        ..['userId'] = userId,
    );
  }

  Future<List<SyncQueueItem>> getQueueItems() async {
    final userId = _readUserId();
    if (userId == null) return [];
    await ensureInitialized();
    final rows = await _database!.query(
      'sync_queue',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(SyncQueueItem.fromMap).toList();
  }

  Future<int> deleteQueueItem(int id) async {
    final userId = _requireUserId();
    await ensureInitialized();
    return _database!.delete(
      'sync_queue',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // ── Internal helpers ────────────────────────────────────────────────────────

  Future<Map<String, Object?>?> _findSaleStockProduct(
    Transaction txn,
    String userId,
  ) async {
    final rows = await txn.query(
      _productsTable,
      where: 'stock > 0 AND userId = ?',
      whereArgs: [userId],
      orderBy: 'stock DESC, name ASC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> _findPurchaseStockProduct(
    Transaction txn,
    String supplierName,
    String userId,
  ) async {
    final supplierRows = await txn.query(
      _productsTable,
      where: 'supplier = ? AND userId = ?',
      whereArgs: [supplierName, userId],
      orderBy: 'name ASC',
      limit: 1,
    );
    if (supplierRows.isNotEmpty) return supplierRows.first;

    final rows = await txn.query(
      _productsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> _restoreStock(
    Transaction txn,
    Map<String, Object?> transactionRow,
    String userId,
  ) async {
    final productId = transactionRow['stockProductId'] as int?;
    final quantity  = transactionRow['stockQuantity'] as int? ?? 0;
    if (productId == null || quantity <= 0) return;

    final products = await txn.query(
      _productsTable,
      columns: ['stock'],
      where: 'id = ? AND userId = ?',
      whereArgs: [productId, userId],
      limit: 1,
    );
    if (products.isEmpty) return;

    await txn.update(
      _productsTable,
      {'stock': (products.first['stock'] as int) + quantity},
      where: 'id = ? AND userId = ?',
      whereArgs: [productId, userId],
    );
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

