import '../../../models/sales_model.dart';
import '../../../data/database/database_helper.dart';

class SalesRepository {
  SalesRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<SalesModel>> fetchSales() {
    return _databaseHelper.getSales();
  }

  Future<void> addSale(SalesModel sale) {
    return _databaseHelper.insertSale(sale);
  }

  Future<int> deleteSale(String saleId) {
    return _databaseHelper.deleteSale(saleId);
  }
}
