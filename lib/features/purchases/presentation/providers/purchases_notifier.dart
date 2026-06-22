import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/purchase_model.dart';
import '../../data/purchases_repository.dart';

class PurchasesNotifier extends StateNotifier<AsyncValue<List<PurchaseModel>>> {
  PurchasesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPurchases();
  }

  final PurchasesRepository _repository;

  Future<void> loadPurchases() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchPurchases);
  }

  Future<void> addPurchase({
    required String supplierName,
    required double amount,
    required String status,
    required DateTime expectedDelivery,
  }) async {
    final purchase = PurchaseModel(
      id: 'PO-${DateTime.now().millisecondsSinceEpoch}',
      supplierName: supplierName.trim(),
      amount: amount,
      status: status,
      createdAt: DateTime.now(),
      expectedDelivery: expectedDelivery,
    );

    try {
      await _repository.addPurchase(purchase);
      await loadPurchases();
    } catch (e) {
      final current = state.value ?? <PurchaseModel>[];
      state = AsyncValue.data([purchase, ...current]);
    }
  }

  Future<void> deletePurchase(String purchaseId) async {
    try {
      await _repository.deletePurchase(purchaseId);
      await loadPurchases();
    } catch (e) {
      final current = state.value ?? <PurchaseModel>[];
      state = AsyncValue.data(
        current.where((purchase) => purchase.id != purchaseId).toList(),
      );
    }
  }
}
