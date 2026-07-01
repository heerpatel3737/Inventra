import '../../../models/purchase_model.dart';
import '../../../data/database/database_helper.dart';
import '../../../models/sync_queue_item.dart';
import '../../../services/sync_service.dart';

class PurchasesRepository {
  PurchasesRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<PurchaseModel>> fetchPurchases() {
    return _databaseHelper.getPurchases();
  }

  Future<void> addPurchase(PurchaseModel purchase) async {
    await _databaseHelper.insertPurchase(purchase);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'purchases',
      action: 'CREATE',
      recordId: purchase.id,
      data: purchase.toMap(),
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
  }

  Future<int> deletePurchase(String purchaseId) async {
    final rowsAffected = await _databaseHelper.deletePurchase(purchaseId);
    await _databaseHelper.insertQueueItem(SyncQueueItem(
      collection: 'purchases',
      action: 'DELETE',
      recordId: purchaseId,
      data: const {},
      createdAt: DateTime.now(),
    ));
    SyncService.instance.syncQueue();
    return rowsAffected;
  }
}
