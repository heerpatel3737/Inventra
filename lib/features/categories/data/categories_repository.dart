import '../../../data/database/database_helper.dart';
import '../../../models/category_model.dart';
import '../../../models/sync_queue_item.dart';
import '../../../services/sync_service.dart';

class CategoriesRepository {
  CategoriesRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<CategoryModel>> fetchCategories() {
    return _databaseHelper.getCategories();
  }

  Future<void> saveCategory(CategoryModel category) async {
    await _databaseHelper.upsertCategory(category);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'categories',
      action: 'UPDATE',
      recordId: category.id,
      data: category.toMap(),
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
  }

  Future<int> deleteCategory(String categoryId) async {
    final rowsAffected = await _databaseHelper.deleteCategory(categoryId);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'categories',
      action: 'DELETE',
      recordId: categoryId,
      data: const {},
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
    return rowsAffected;
  }
}
