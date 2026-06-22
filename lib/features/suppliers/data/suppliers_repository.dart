import '../../../data/database/database_helper.dart';
import '../../../models/supplier_model.dart';
import '../../../models/sync_queue_item.dart';
import '../../../services/sync_service.dart';

class SuppliersRepository {
  SuppliersRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<SupplierModel>> fetchSuppliers() {
    return _databaseHelper.getSuppliers();
  }

  Future<void> saveSupplier(SupplierModel supplier) async {
    await _databaseHelper.upsertSupplier(supplier);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'suppliers',
      action: 'UPDATE',
      recordId: supplier.id,
      data: supplier.toMap(),
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
  }

  Future<int> deleteSupplier(String supplierId) async {
    final rowsAffected = await _databaseHelper.deleteSupplier(supplierId);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'suppliers',
      action: 'DELETE',
      recordId: supplierId,
      data: const {},
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
    return rowsAffected;
  }
}
