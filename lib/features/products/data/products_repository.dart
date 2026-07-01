import '../../../data/database/database_helper.dart';
import '../../../data/models/product_model.dart';
import '../../../models/sync_queue_item.dart';
import '../../../services/sync_service.dart';

/// Repository: the only place the presentation layer talks to SQLite for products.
class ProductsRepository {
  ProductsRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<ProductModel>> fetchProducts() {
    return _databaseHelper.getProducts();
  }

  Future<int> addProduct({
    required String name,
    required String category,
    required String supplier,
    required int stock,
    required double price,
    String? imageUrl,
    String? barcode,
  }) async {
    final product = ProductModel(
      name: name,
      category: category,
      supplier: supplier,
      stock: stock,
      price: price,
      imageUrl: imageUrl,
      barcode: barcode,
    );
    final id = await _databaseHelper.insertProduct(product);
    final savedProduct = product.copyWith(id: id);

    // Enqueue action for Firestore synchronization
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'products',
      action: 'CREATE',
      recordId: id.toString(),
      data: savedProduct.toMap(),
      createdAt: DateTime.now(),
    ));

    // Attempt synchronization in the background
    SyncService.instance.syncQueue();

    return id;
  }

  Future<int> updateProduct(ProductModel product) async {
    final rowsAffected = await _databaseHelper.updateProduct(product);
    if (product.id != null) {
      await _databaseHelper.insertQueueItem(SyncQueueItem(
        collection: 'products',
        action: 'UPDATE',
        recordId: product.id!.toString(),
        data: product.toMap(),
        createdAt: DateTime.now(),
      ));
      SyncService.instance.syncQueue();
    }
    return rowsAffected;
  }

  Future<int> deleteProduct(int productId) async {
    final rowsAffected = await _databaseHelper.deleteProduct(productId);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'products',
      action: 'DELETE',
      recordId: productId.toString(),
      data: const {},
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
    return rowsAffected;
  }
}
