import '../../../models/sales_model.dart';
import '../../../data/database/database_helper.dart';
import '../../../models/sync_queue_item.dart';
import '../../../services/sync_service.dart';

class SalesRepository {
  SalesRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<SalesModel>> fetchSales() {
    return _databaseHelper.getSales();
  }

  Future<void> addSale(SalesModel sale) async {
    await _databaseHelper.insertSale(sale);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'sales',
      action: 'CREATE',
      recordId: sale.id,
      data: sale.toMap(),
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
  }

  Future<int> deleteSale(String saleId) async {
    final rowsAffected = await _databaseHelper.deleteSale(saleId);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'sales',
      action: 'DELETE',
      recordId: saleId,
      data: const {},
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
    return rowsAffected;
  }
}
