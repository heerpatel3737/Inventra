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
  static const _databaseVersion = 2;
  static const _productsTable = 'products';
  static const _categoriesTable = 'categories';
  static const _suppliersTable = 'suppliers';
  static const _salesTable = 'sales';
  static const _purchasesTable = 'purchases';
  static const _notificationsTable = 'notifications';
  static const _rolesTable = 'roles';
  static const _profileTable = 'user_profile';
  static const _syncStatusTable = 'sync_status';

  Database? _database;
  bool _ffiInitialized = false;

  Future<void> ensureInitialized() async {
    if (_database != null) return;

    _initializeDesktopDatabaseFactory();

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) => _createSchema(db),
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

  Future<void> _createSchema(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS $_productsTable (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  stock INTEGER NOT NULL CHECK(stock >= 0),
  category TEXT NOT NULL,
  supplier TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_categoriesTable (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL DEFAULT '',
  totalProducts INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_suppliersTable (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  address TEXT NOT NULL,
  status TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_salesTable (
  id TEXT PRIMARY KEY,
  clientName TEXT NOT NULL,
  amount REAL NOT NULL,
  status TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  stockProductId INTEGER,
  stockQuantity INTEGER NOT NULL DEFAULT 1
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_purchasesTable (
  id TEXT PRIMARY KEY,
  supplierName TEXT NOT NULL,
  amount REAL NOT NULL,
  status TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  expectedDelivery TEXT NOT NULL,
  stockProductId INTEGER,
  stockQuantity INTEGER NOT NULL DEFAULT 1
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_notificationsTable (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  isRead INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_rolesTable (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  permissions TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_profileTable (
  id INTEGER PRIMARY KEY CHECK(id = 1),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL,
  phone TEXT NOT NULL,
  department TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $_syncStatusTable (
  id INTEGER PRIMARY KEY CHECK(id = 1),
  lastSuccessfulSync TEXT,
  pendingRecords INTEGER NOT NULL DEFAULT 0,
  conflictCount INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  collection TEXT NOT NULL,
  action TEXT NOT NULL,
  recordId TEXT NOT NULL,
  data TEXT NOT NULL,
  createdAt TEXT NOT NULL
)
''');
  }

  Future<int> insertProduct(ProductModel product) async {
    await ensureInitialized();
    return _database!.insert(
      _productsTable,
      product.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<ProductModel>> getProducts() async {
    await ensureInitialized();
    final rows = await _database!.query(_productsTable, orderBy: 'name ASC');
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    if (product.id == null) {
      throw Exception('Cannot update a product without an id.');
    }

    await ensureInitialized();
    return _database!.update(
      _productsTable,
      product.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    await ensureInitialized();
    return _database!.delete(_productsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CategoryModel>> getCategories() async {
    await ensureInitialized();
    final rows = await _database!.query(_categoriesTable, orderBy: 'name ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<void> upsertCategory(CategoryModel category) async {
    await ensureInitialized();
    await _database!.insert(
      _categoriesTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteCategory(String id) async {
    await ensureInitialized();
    return _database!.delete(_categoriesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SupplierModel>> getSuppliers() async {
    await ensureInitialized();
    final rows = await _database!.query(_suppliersTable, orderBy: 'name ASC');
    return rows.map(SupplierModel.fromMap).toList();
  }

  Future<void> upsertSupplier(SupplierModel supplier) async {
    await ensureInitialized();
    await _database!.insert(
      _suppliersTable,
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteSupplier(String id) async {
    await ensureInitialized();
    return _database!.delete(_suppliersTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SalesModel>> getSales() async {
    await ensureInitialized();
    final rows = await _database!.query(_salesTable, orderBy: 'createdAt DESC');
    return rows.map(SalesModel.fromMap).toList();
  }

  Future<void> insertSale(SalesModel sale) async {
    await ensureInitialized();
    await _database!.transaction((txn) async {
      final product = await _findSaleStockProduct(txn);
      if (product == null) {
        throw Exception('Sale blocked: no stock is available.');
      }

      final productId = product['id'] as int;
      final currentStock = product['stock'] as int;
      if (currentStock <= 0) {
        throw Exception('Sale blocked: stock cannot go negative.');
      }

      await txn.update(
        _productsTable,
        {'stock': currentStock - 1},
        where: 'id = ?',
        whereArgs: [productId],
      );
      await txn.insert(
        _salesTable,
        {
          ...sale.toMap(),
          'stockProductId': productId,
          'stockQuantity': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<int> deleteSale(String id) async {
    await ensureInitialized();
    return _database!.transaction((txn) async {
      final rows = await txn.query(_salesTable, where: 'id = ?', whereArgs: [id], limit: 1);
      if (rows.isEmpty) return 0;

      await _restoreStock(txn, rows.first);
      return txn.delete(_salesTable, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<PurchaseModel>> getPurchases() async {
    await ensureInitialized();
    final rows = await _database!.query(_purchasesTable, orderBy: 'createdAt DESC');
    return rows.map(PurchaseModel.fromMap).toList();
  }

  Future<void> insertPurchase(PurchaseModel purchase) async {
    await ensureInitialized();
    await _database!.transaction((txn) async {
      final product = await _findPurchaseStockProduct(txn, purchase.supplierName);
      final productId = product?['id'] as int?;

      if (productId != null) {
        await txn.update(
          _productsTable,
          {'stock': (product!['stock'] as int) + 1},
          where: 'id = ?',
          whereArgs: [productId],
        );
      }

      await txn.insert(
        _purchasesTable,
        {
          ...purchase.toMap(),
          'stockProductId': productId,
          'stockQuantity': productId == null ? 0 : 1,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<int> deletePurchase(String id) async {
    await ensureInitialized();
    return _database!.transaction((txn) async {
      final rows = await txn.query(_purchasesTable, where: 'id = ?', whereArgs: [id], limit: 1);
      if (rows.isEmpty) return 0;

      final productId = rows.first['stockProductId'] as int?;
      final quantity = rows.first['stockQuantity'] as int? ?? 0;
      if (productId != null && quantity > 0) {
        final products = await txn.query(
          _productsTable,
          columns: ['stock'],
          where: 'id = ?',
          whereArgs: [productId],
          limit: 1,
        );
        if (products.isNotEmpty) {
          final currentStock = products.first['stock'] as int;
          if (currentStock - quantity < 0) {
            throw Exception('Purchase delete blocked: stock cannot go negative.');
          }
          await txn.update(
            _productsTable,
            {'stock': currentStock - quantity},
            where: 'id = ?',
            whereArgs: [productId],
          );
        }
      }

      return txn.delete(_purchasesTable, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<NotificationModel>> getNotifications() async {
    await ensureInitialized();
    final rows = await _database!.query(_notificationsTable, orderBy: 'createdAt DESC');
    return rows.map(NotificationModel.fromMap).toList();
  }

  Future<void> upsertNotification(NotificationModel notification) async {
    await ensureInitialized();
    await _database!.insert(
      _notificationsTable,
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> replaceStockNotifications(List<NotificationModel> notifications) async {
    await ensureInitialized();
    await _database!.transaction((txn) async {
      await txn.delete(_notificationsTable, where: 'id LIKE ?', whereArgs: ['stock-%']);
      for (final notification in notifications) {
        await txn.insert(
          _notificationsTable,
          notification.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> markNotificationAsRead(String id) async {
    await ensureInitialized();
    await _database!.update(_notificationsTable, {'isRead': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllNotificationsAsRead() async {
    await ensureInitialized();
    await _database!.update(_notificationsTable, {'isRead': 1});
  }

  Future<int> deleteNotification(String id) async {
    await ensureInitialized();
    return _database!.delete(_notificationsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RoleModel>> getRoles() async {
    await ensureInitialized();
    final rows = await _database!.query(_rolesTable, orderBy: 'name ASC');
    return rows.map(RoleModel.fromMap).toList();
  }

  Future<void> upsertRole(RoleModel role) async {
    await ensureInitialized();
    await _database!.insert(_rolesTable, role.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserProfileModel> getProfile() async {
    await ensureInitialized();
    final rows = await _database!.query(_profileTable, where: 'id = 1', limit: 1);
    if (rows.isEmpty) {
      const profile = UserProfileModel(
        name: '',
        email: '',
        role: '',
        phone: '',
        department: '',
      );
      await upsertProfile(profile);
      return profile;
    }
    return UserProfileModel.fromMap(rows.first);
  }

  Future<void> upsertProfile(UserProfileModel profile) async {
    await ensureInitialized();
    await _database!.insert(
      _profileTable,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SyncStatusModel> getSyncStatus() async {
    await ensureInitialized();
    final rows = await _database!.query(_syncStatusTable, where: 'id = 1', limit: 1);
    if (rows.isEmpty) {
      const status = SyncStatusModel();
      await upsertSyncStatus(status);
      return status;
    }
    return SyncStatusModel.fromMap(rows.first);
  }

  Future<void> upsertSyncStatus(SyncStatusModel status) async {
    await ensureInitialized();
    await _database!.insert(
      _syncStatusTable,
      status.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Object?>?> _findSaleStockProduct(Transaction txn) async {
    final rows = await txn.query(
      _productsTable,
      where: 'stock > 0',
      orderBy: 'stock DESC, name ASC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> _findPurchaseStockProduct(
    Transaction txn,
    String supplierName,
  ) async {
    final supplierRows = await txn.query(
      _productsTable,
      where: 'supplier = ?',
      whereArgs: [supplierName],
      orderBy: 'name ASC',
      limit: 1,
    );
    if (supplierRows.isNotEmpty) return supplierRows.first;

    final rows = await txn.query(_productsTable, orderBy: 'name ASC', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> _restoreStock(Transaction txn, Map<String, Object?> transactionRow) async {
    final productId = transactionRow['stockProductId'] as int?;
    final quantity = transactionRow['stockQuantity'] as int? ?? 0;
    if (productId == null || quantity <= 0) return;

    final products = await txn.query(
      _productsTable,
      columns: ['stock'],
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (products.isEmpty) return;

    await txn.update(
      _productsTable,
      {'stock': (products.first['stock'] as int) + quantity},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> insertQueueItem(SyncQueueItem item) async {
    await ensureInitialized();
    return _database!.insert('sync_queue', item.toMap()..remove('id'));
  }

  Future<List<SyncQueueItem>> getQueueItems() async {
    await ensureInitialized();
    final rows = await _database!.query('sync_queue', orderBy: 'createdAt ASC');
    return rows.map(SyncQueueItem.fromMap).toList();
  }

  Future<int> deleteQueueItem(int id) async {
    await ensureInitialized();
    return _database!.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
