import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/sales_model.dart';
import '../../data/sales_repository.dart';

class SalesNotifier extends StateNotifier<AsyncValue<List<SalesModel>>> {
  SalesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSales();
  }

  final SalesRepository _repository;

  Future<void> loadSales() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchSales);
  }

  Future<void> addSale({
    required String clientName,
    required double amount,
    required String status,
  }) async {
    final sale = SalesModel(
      id: 'SO-${DateTime.now().millisecondsSinceEpoch}',
      clientName: clientName.trim(),
      amount: amount,
      status: status,
      createdAt: DateTime.now(),
    );

    try {
      await _repository.addSale(sale);
      await loadSales();
    } catch (e) {
      final current = state.value ?? <SalesModel>[];
      state = AsyncValue.data([sale, ...current]);
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      await _repository.deleteSale(saleId);
      await loadSales();
    } catch (e) {
      final current = state.value ?? <SalesModel>[];
      state = AsyncValue.data(
        current.where((sale) => sale.id != saleId).toList(),
      );
    }
  }
}
