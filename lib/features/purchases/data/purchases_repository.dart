import '../../../models/purchase_model.dart';
import '../../../data/database/database_helper.dart';

class PurchasesRepository {
  PurchasesRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<PurchaseModel>> fetchPurchases() {
    return _databaseHelper.getPurchases();
  }

  Future<void> addPurchase(PurchaseModel purchase) {
    return _databaseHelper.insertPurchase(purchase);
  }

  Future<int> deletePurchase(String purchaseId) {
    return _databaseHelper.deletePurchase(purchaseId);
  }
}
